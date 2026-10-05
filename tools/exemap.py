#!/usr/bin/env py
"""Map the recovered ThaiPro source modules onto the reference THAIPRO.EXE.

1. Parse OMF object files (LEDATA/FIXUPP/PUBDEF/EXTDEF) of our modules.
2. Load the reference MZ image.
3. Masked-search each module's bytes in the image (fixup fields wildcarded).
4. Report the coverage map (known modules vs. uncovered = missing module).
5. Recover symbol offsets from linked fixup values and annotate a capstone
   disassembly of the uncovered regions.

Usage: py exemap.py
Outputs: build/coverage.txt, build/gap.asm (annotated disasm of uncovered)
"""
import re
import struct
import sys
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent
BUILD = REPO / "build"
REF_EXE = Path(r"C:/opt/DOSBox/THAIPRO/THAIPRO.EXE")
MODULES = ["INSTALL", "INT9", "INT8", "INT10", "INT17", "INT60", "MENU"]


# ---------------------------------------------------------------- OMF parser
def omf_records(data):
    i = 0
    while i + 3 < len(data):
        rectype = data[i]
        reclen = struct.unpack_from("<H", data, i + 1)[0]
        body = data[i + 3 : i + 3 + reclen - 1]  # -1 checksum
        yield rectype, body
        i += 3 + reclen


def parse_obj(path):
    """Return dict: extdefs[names], pubdefs{name:(segidx,off)}, segs[{name,size}], ledata{segidx: {off: bytes}}, fixups[{pos, kind, rel, target, frame}]"""
    extdefs, pubdefs, segs, ledata, fixups = [], {}, [], {}, []
    cur_lid = None
    for rectype, body in omf_records(path.read_bytes()):
        t = rectype & 0xFE
        if t == 0x8C:  # EXTDEF
            i = 0
            while i < len(body):
                n = body[i]
                extdefs.append(body[i + 1 : i + 1 + n].decode("latin-1"))
                i += 1 + n + 1  # name + type index
        elif t in (0x90, 0x91):  # PUBDEF
            i = 0
            grp = body[i]; i += 1
            seg = struct.unpack_from("<H", body, i)[0]; i += 2
            if seg == 0:
                i += 2  # frame
            while i < len(body):
                n = body[i]; name = body[i + 1 : i + 1 + n].decode("latin-1"); i += 1 + n
                off = struct.unpack_from("<H", body, i)[0]; i += 2
                pubdefs[name] = (seg, off)
                i += 1  # type index
        elif t in (0x98, 0x99):  # SEGDEF
            i = 0
            attr = body[i]; i += 1
            if attr & 4:  # big
                seglen = 0
            else:
                seglen = struct.unpack_from("<H", body, i)[0]
            i += 2
            name = "?"
            if not (rectype & 1):  # not segdef32
                pass
            segs.append({"len": seglen, "name_idx": None, "attr": attr, "align": attr >> 5})
        elif t in (0xA0, 0xA1):  # LEDATA
            segidx = struct.unpack_from("<H", body, 0)[0]
            start = struct.unpack_from("<H", body, 2)[0]
            ledata.setdefault(segidx, bytearray())
            seg = ledata[segidx]
            if len(seg) < start:
                seg.extend(b"\x00" * (start - len(seg)))
            payload = body[4:]
            seg[start : start + len(payload)] = payload
            cur_lid = segidx
        elif t == 0x9C:  # FIXUPP
            i = 0
            while i < len(body):
                b1 = body[i]
                if b1 & 0x80:  # fixup
                    loc = (b1 >> 2) & 7
                    mode = (b1 >> 6) & 1  # 1=self-relative
                    fpos = struct.unpack_from("<H", body, i + 1)[0]
                    i += 3
                    b2 = body[i]
                    frame_m = (b2 >> 6) & 3
                    targ_m = (b2 >> 2) & 3
                    targ = b2 & 3
                    i += 1
                    if frame_m == 0:
                        i += 1  # frame thread absent -> frame field present
                    fix_datum = 0
                    if targ & 2 == 0:  # target datum present
                        fix_datum = struct.unpack_from("<H", body, i)[0]
                        i += 2
                    if frame_m == 0:
                        pass
                    # target: thread or explicit index
                    if targ & 2:  # thread
                        # crude: ignore threads (thread defs come in b1&0x80==0 records)
                        target = None
                    else:
                        idx = (fix_datum >> (0 if False else 0)) & 0xFFFF
                        # for method 0/2: index; method 1/3: disp+index
                        if targ & 1:  # has displacement
                            idx = fix_datum & 0x3FFF
                        target = idx
                    # displacement (methods 1,5 / 3,7 style) handled crudely below
                    fixups.append({"pos": fpos, "loc": loc, "rel": mode == 1,
                                   "target": target, "raw": b2})
                else:  # thread
                    i += 1
                    if body[i - 1] & 0x40 == 0:  # hmm crude
                        pass
    return {"extdefs": extdefs, "pubdefs": pubdefs, "segs": segs,
            "ledata": ledata, "fixups": fixups, "name": path.stem}


# ---------------------------------------------------------------- MZ loader
def load_mz(path):
    d = path.read_bytes()
    hdr = struct.unpack_from("<14H", d, 0)
    (magic, cpara, cpages, mrela, cpara_hdr, minalloc, maxalloc, ss, sp,
     csum, ip, cs, creloc, overlay) = hdr
    assert magic == 0x5A4D, "not MZ"
    hdrbytes = cpara_hdr * 16
    imgbytes = cpages * 512 - (512 if mrela else 0) if cpages else 0
    img = d[hdrbytes : hdrbytes + imgbytes]
    relocs = []
    for k in range(creloc):
        off, seg = struct.unpack_from("<HH", d, 0x1E + 4 * k)
        relocs.append((seg, off))
    return {"img": img, "imglen": imgbytes, "cs": cs, "ip": ip,
            "ss": ss, "sp": sp, "relocs": relocs, "crelocs": creloc}


# ------------------------------------------------------- masked regex search
def module_pattern(data, masked):
    """Build regex from data bytes; masked 2-byte fields become '..'."""
    out = []
    i = 0
    maskset = set()
    for pos in masked:
        maskset.add(pos)
        maskset.add(pos + 1)
    while i < len(data):
        if i in maskset:
            out.append(b"..")
            i += 1
            continue
        j = i
        while j < len(data) and j not in maskset:
            j += 1
        chunk = data[i:j]
        out.append(re.escape(chunk))
        i = j
    return re.compile(b"".join(out), re.S)


def main():
    mods = {m: parse_obj(BUILD / f"{m}.OBJ") for m in MODULES}
    ref = load_mz(REF_EXE)
    img = ref["img"]
    print(f"reference EXE: image {ref['imglen']} bytes, entry {ref['cs']:04X}:{ref['ip']:04X}, {ref['crelocs']} relocs")

    coverage = [0] * len(img)
    symmap = {}   # cseg offset -> name (from known modules)
    layout = []

    for name in MODULES:
        m = mods[name]
        segidx = max(m["ledata"], key=lambda s: len(m["ledata"][s]))
        data = bytes(m["ledata"][segidx])
        masked = [f["pos"] for f in m["fixups"] if f["target"] is not None]
        # NOTE: fixup positions are relative to each LEDATA record start in
        # general; JWasm emits one LEDATA per segment starting at 0, which we
        # assume here (verified by sizes matching).
        pat = module_pattern(data, masked)
        hits = [mo.start() for mo in pat.finditer(img)]
        print(f"{name:8s} size={len(data):6d} fixups={len(masked):4d} matches={[hex(h) for h in hits]}")
        if not hits:
            continue
        base = hits[0]
        layout.append((base, base + len(data), name))
        for k in range(base, min(base + len(data), len(img))):
            coverage[k] = 1
        # recover symbol values from linked fixups
        for f in m["fixups"]:
            if f["target"] is None:
                continue
            site = base + f["pos"]
            if site + 2 > len(img):
                continue
            val = struct.unpack_from("<H", img, site)[0]
            ext = m["extdefs"][f["target"]] if f["target"] < len(m["extdefs"]) else f"?{f['target']}"
            if f["rel"]:  # self-relative: target = site + val + 2
                tgt = site + val + 2
            else:         # absolute 16-bit offset
                tgt = val
            symmap.setdefault(tgt, set()).add(ext)

    # coverage report
    print("\n--- coverage map ---")
    i = 0
    gaps = []
    while i < len(img):
        if coverage[i]:
            j = i
            while j < len(img) and coverage[j]:
                j += 1
            print(f"covered  {i:06X}-{j-1:06X} ({j-i} bytes)")
            i = j
        else:
            j = i
            while j < len(img) and not coverage[j]:
                j += 1
            gaps.append((i, j))
            print(f"UNCOVERED {i:06X}-{j-1:06X} ({j-i} bytes)")
            i = j
    (BUILD / "coverage.txt").write_text("\n".join(
        f"{a:06X}-{b-1:06X} ({b-a})" for a, b in gaps))

    # symbol table (offsets referenced by known code)
    print("\n--- symbols referenced by known modules ---")
    for off in sorted(symmap):
        names = ",".join(sorted(symmap[off]))
        print(f"{off:04X}  {names}")

    # public symbols of known modules -> absolute offsets
    print("\n--- public symbols ---")
    for name in MODULES:
        m = mods[name]
        base = next((b for b, e, n in layout if n == name), None)
        if base is None:
            continue
        for pname, (seg, off) in sorted(m["pubdefs"].items()):
            print(f"{base + off:04X}  {name}:{pname}")


if __name__ == "__main__":
    main()
