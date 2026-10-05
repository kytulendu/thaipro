#!/usr/bin/env py
"""Map recovered ThaiPro modules onto reference THAIPRO.EXE via JWasm listings.

Pipeline (no OMF parsing):
1. Assemble each module with -Fl and parse the listing: byte image, fixup
   sites (operands marked 'o'/'r'), label offsets.
2. Find each module's base in the reference image by matching long exact
   byte runs (majority vote).
3. Read fixup values from the reference image -> symbol -> CSEG offset map
   for every EXTRN (including the ones missing from the partial source).
4. Report coverage; disassemble uncovered regions with capstone, annotated.

Usage: py exemap2.py [--disasm]
"""
import re
import struct
import subprocess
import sys
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent
BUILD = REPO / "build"
REF_EXE = Path(r"C:/opt/DOSBox/THAIPRO/THAIPRO.EXE")
JWASM = REPO / "tools" / "JWasm.exe"
MODULES = ["INSTALL", "INT9", "INT8", "INT10", "INT17", "INT60", "MENU"]

LINE_RE = re.compile(
    r"^\s*([0-9A-F]{4})((?:\s+[0-9A-F]{2,}[ore]?(?![0-9A-F]))+)(\s+)(.*)$")
HEXTOK = re.compile(r"^([0-9A-F]+)([ore])?$")


def parse_listing(path, extrns=frozenset()):
    """Return (bytes, fixes {pos:(len,mark,srcwords)}, labels {off:name})"""
    data = bytearray()
    fixes = {}
    labels = {}
    fixgroups = []
    codemask = bytearray()
    segs = []
    cur_data, cur_fixes, cur_labels = bytearray(), {}, {}
    cur_group = None
    cur_code = bytearray()
    prev_off = -1
    for raw in path.read_text(errors="replace").splitlines():
        m = LINE_RE.match(raw)
        if not m:
            continue
        off = int(m.group(1), 16)
        toks = m.group(2).split()
        rest = m.group(4)
        if off <= prev_off and prev_off >= 0 and off <= 16:
            segs.append((cur_data, cur_fixes, cur_labels, fixgroups, cur_code))
            cur_data, cur_fixes, cur_labels = bytearray(), {}, {}
            fixgroups, cur_code = [], bytearray()
            cur_group = None
            prev_off = -1
        # data-line detection: source starts with optional label then DB/DW/DD
        rt = rest.split()
        is_data = any(t.upper() in ("DB", "DW", "DD") for t in rt[:2])
        # strip comment for identifier extraction
        code_txt = rest.split(";")[0]
        found = []
        for w in re.findall(r"[A-Za-z_$?@][\w$?@]*", code_txt.upper()):
            if w in extrns and w not in found:
                found.append(w)
        if found:
            cur_group = {"sites": {}, "names": found}
            fixgroups.append(cur_group)
        pos = off
        for tok in toks:
            hm = HEXTOK.match(tok)
            if not hm:
                continue
            hexs, mark = hm.group(1), hm.group(2)
            if len(hexs) % 2:
                print(f"  !! odd hex token {tok!r} at {off:04X}")
                continue
            b = bytes.fromhex(hexs)
            if mark:
                # JWasm listing displays marked operands as their VALUE
                # (big-endian display); memory order is little-endian.
                b = b[::-1]
            if len(cur_data) < pos:
                cur_data.extend(b"\x00" * (pos - len(cur_data)))
                cur_code.extend(b"\x00" * (pos - len(cur_code)))
            cur_data[pos : pos + len(b)] = b
            if not is_data:
                cur_code[pos : pos + len(b)] = b"\x01" * len(b)
            if mark:
                cur_fixes[pos] = (len(b), mark)
                if cur_group is not None:
                    cur_group["sites"][pos] = (len(b), mark)
            pos += len(b)
        prev_off = off
        t = rest.split()
        if t:
            name = t[0]
            if name.endswith(":") and re.match(r"^[A-Za-z_$?@][\w$?@]*:$", name):
                cur_labels[off] = name[:-1]
            elif len(t) > 1 and t[1].upper() in ("PROC", "ENDP", "LABEL") and \
                    re.match(r"^[A-Za-z_$?@][\w$?@]*$", name):
                cur_labels[off] = name
    segs.append((cur_data, cur_fixes, cur_labels, fixgroups, cur_code))
    for s in segs:
        if len(s[4]) < len(s[0]):
            s[4].extend(b"\x00" * (len(s[0]) - len(s[4])))
    seg = max(segs, key=lambda s: len(s[0]))
    return seg


def build_module(name):
    lst = BUILD / f"{name}.LST"
    src = REPO / "src" / f"{name}.ASM"
    if not lst.exists() or lst.stat().st_mtime < src.stat().st_mtime:
        subprocess.run([str(JWASM), "-Cu", "-q", f"-Fl={lst}", str(src)], check=True)
    srctxt = src.read_bytes().decode("latin-1").upper()
    extrns = set(re.findall(r"\bEXTRN\b([^\n]*)", srctxt))
    extrns = set(re.findall(r"[A-Za-z_$?@][\w$?@]*", " ".join(extrns)))
    extrns -= {"EXTRN", "NEAR", "FAR", "BYTE", "WORD", "DWORD"}
    data, fixes, labels, fixgroups, codemask = parse_listing(lst, extrns)
    return {"name": name, "data": bytes(data), "fixes": fixes, "labels": labels,
            "extrns": extrns, "fixgroups": fixgroups, "codelines": codemask}


def load_mz(path):
    d = path.read_bytes()
    (magic, cpara, cpages, mrela, cpara_hdr, minalloc, maxalloc, ss, sp,
     csum, ip, cs, creloc, overlay) = struct.unpack_from("<14H", d, 0)
    hdrbytes = cpara_hdr * 16
    total = cpages * 512 - (512 - mrela if mrela else 0)
    img = d[hdrbytes:hdrbytes + total]
    return {"img": img, "hdrbytes": hdrbytes, "cs": cs, "ip": ip, "total": total}


def find_base(mod, img, min_run=10):
    """Vote for module base using CODE-only runs (skip DB/data lines, holes)."""
    data = mod["data"]
    fixes = sorted(mod["fixes"])
    code_lines = mod.get("codelines", set())  # (start,end) assigned by code lines
    runs = []
    prev = 0
    bounds = sorted(set(list(fixes) + [p + mod["fixes"][p][0] for p in fixes]))
    for p in bounds:
        if p - prev >= min_run:
            runs.append((prev, data[prev:p]))
        prev = p + mod["fixes"][p][0] if p in fixes else p
    if len(data) - prev >= min_run:
        runs.append((prev, data[prev:]))
    votes = {}
    for roff, r in runs:
        # skip runs that contain unassigned (hole) bytes
        if code_lines and not all(code_lines[roff + k] for k in range(len(r))):
            continue
        start = 0
        while True:
            i = img.find(r, start)
            if i < 0:
                break
            b = i - roff
            votes[b] = votes.get(b, 0) + len(r)
            start = i + 1
    if not votes:
        return None, votes
    ranked = sorted(votes.items(), key=lambda kv: -kv[1])
    best = ranked[0][0]
    return best, votes


def main():
    disasm = "--disasm" in sys.argv
    ref = load_mz(REF_EXE)
    img = ref["img"]
    print(f"reference: file={REF_EXE.stat().st_size} hdr={ref['hdrbytes']} "
          f"img={len(img)} entry={ref['cs']:04X}:{ref['ip']:04X}")

    mods = {}
    symmap = {}   # cseg offset -> set of names
    bases = {}
    for name in MODULES:
        mod = build_module(name)
        mods[name] = mod
        base, votes = find_base(mod, img)
        bases[name] = base
        n = len(mod["data"])
        print(f"{name:8s} len={n:6d} fixups={len(mod['fixes']):4d} "
              f"base={'---' if base is None else hex(base)} "
              f"votes={sorted(votes.values(), reverse=True)[:3]}")
        if base is None:
            continue
        # recover symbol targets per source line (zip sites <-> identifiers)
        for grp in mod["fixgroups"]:
            sites = sorted(grp["sites"])
            names = grp["names"]
            if not names:
                continue
            if len(sites) == len(names):
                pairs = list(zip(sites, names))
            elif len(sites) == 1:
                pairs = [(sites[0], names[0])]
            else:
                continue  # ambiguous line
            for pos, nm in pairs:
                site = base + pos
                if site + 2 > len(img):
                    continue
                val = struct.unpack_from("<H", img, site)[0]
                rel = grp["sites"][pos][1] == "r"
                tgt = site + val + 2 if rel else val
                symmap.setdefault(tgt, set()).add(nm)

    # coverage
    cov = bytearray(len(img))
    for name, base in bases.items():
        if base is None:
            continue
        for k in range(base, min(base + len(mods[name]["data"]), len(img))):
            cov[k] = 1
    print("\n--- coverage ---")
    gaps = []
    i = 0
    while i < len(img):
        j = i
        v = cov[i]
        while j < len(img) and cov[j] == v:
            j += 1
        tag = "covered " if v else "UNCOVERED"
        print(f"{tag} {i:06X}-{j-1:06X} ({j-i})")
        if not v:
            gaps.append((i, j))
        i = j

    # label names for known publics
    print("\n--- labels (known modules) ---")
    labelmap = {}
    for name, base in bases.items():
        if base is None:
            continue
        for off, lname in mods[name]["labels"].items():
            labelmap.setdefault(base + off, set()).add(f"{name}:{lname}")

    if disasm:
        from capstone import Cs, CS_ARCH_X86, CS_MODE_16
        out = []
        md = Cs(CS_ARCH_X86, CS_MODE_16)
        md.skipdata = True
        for a, b in gaps:
            out.append(f"; ===== UNCOVERED {a:04X}-{b-1:04X} =====")
            code = bytes(img[a:b])
            for ins in md.disasm(code, a):
                note = ""
                if ins.address in labelmap:
                    note = " ; " + ",".join(sorted(labelmap[ins.address]))
                tgt = ""
                m = re.match(r"^(call|jmp|j\w+)\s+(0x[0-9a-f]+)$", ins.op_str)
                if m:
                    t = int(m.group(2), 16)
                    names = sorted(symmap.get(t, set())) or sorted(labelmap.get(t, set()))
                    tgt = f"   ; -> {t:04X} {'/'.join(names)}" if names else f"   ; -> {t:04X}"
                out.append(f"{ins.address:04X}  {ins.bytes.hex():<20s} {ins.mnemonic:<8s} {ins.op_str}{tgt}{note}")
        (BUILD / "gap_disasm.txt").write_text("\n".join(out))
        print(f"\nwrote build/gap_disasm.txt ({len(out)} lines)")

    # print symbol targets that fall inside gaps (missing module symbols)
    gapset = set()
    for a, b in gaps:
        gapset.update(range(a, b))
    print("\n--- EXTRN targets inside uncovered regions ---")
    for t in sorted(symmap):
        if t in gapset:
            print(f"{t:04X}  {','.join(sorted(symmap[t]))}")


if __name__ == "__main__":
    main()
