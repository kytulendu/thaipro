#!/usr/bin/env py
"""Align the stub-built THAIPRO image with the reference THAIPRO.EXE image.

1. Load my stub EXE image (MZ stripped) and the reference image.
2. Parse the JWlink MAP: module spans + symbol addresses in MY image.
3. Anchor-match sampled 8-byte windows, extend to maximal runs -> my->ref map.
4. Within aligned regions, diff bytes: 2-byte clusters = fixup sites whose
   target differs (i.e. references into the missing module).
5. Report module bases, coverage gaps, symbol value recovery.
6. Optionally disassemble the uncovered region (capstone, annotated).

Usage: py exemap3.py [--disasm] [--fonts]
"""
import re
import struct
import sys
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent
BUILD = REPO / "build"
REF_EXE = Path(r"C:/opt/DOSBox/THAIPRO/THAIPRO.EXE")
STUB_EXE = BUILD / "THAIPRO.EXE"
MAPFILE = BUILD / "THAIPRO.MAP"

MISSING = ["CRT_MODE", "IndexPort", "OldPage", "NewPage", "CursorLevel",
           "NewVisit", "CurPoint", "RWoffset", "SAHAoffset", "ITAoffset",
           "EnglishMode", "Clscreen", "ClscreenOdd", "ClscreenOrg", "Setmode",
           "HardCur", "TransCurpos", "INCODE5", "INCODE6", "INCODE7",
           "INCODE52", "OffsetCode2", "PROTECT_A000H"]


def load_mz(path):
    d = path.read_bytes()
    (magic, cpara, cpages, mrela, cpara_hdr, *_rest) = struct.unpack_from("<14H", d, 0)
    hdrbytes = cpara_hdr * 16
    total = cpages * 512 - (512 - mrela if mrela else 0)
    return d[hdrbytes:hdrbytes + total]


def parse_map():
    """Return (modules ordered [(name, base)], symbols {name: offset})."""
    txt = MAPFILE.read_text(errors="replace")
    mods = []
    syms = {}
    cur = None
    in_map = False
    for line in txt.splitlines():
        if line.startswith("Address ") and "Symbol" in line:
            in_map = True
            continue
        if not in_map:
            m = re.match(r"^(\S+)\s+(CODE|STACK)\s+AUTO\s+[0-9A-F]{4}:([0-9A-F]{4})\s+([0-9A-F]{8})", line)
            if m:
                mods.append((m.group(1), int(m.group(3), 16), int(m.group(4), 16)))
            continue
        m = re.match(r"^Module: (.+)$", line)
        if m:
            name = Path(m.group(1)).stem
            cur = name
            continue
        m = re.match(r"^([0-9A-F]{4}):([0-9A-F]{4})(\*|\+)?\s+(\S+)$", line)
        if m and cur:
            off = int(m.group(2), 16)
            syms.setdefault(m.group(4), off)
    return mods, syms


def align(mine, ref):
    """Return sorted list of (my_off, ref_off, length) maximal match runs."""
    anchors = {}
    step = 32
    L = 10
    for start in range(0, len(mine) - L, step):
        w = mine[start:start + L]
        i = ref.find(w)
        if i < 0:
            continue
        # extend
        a = start
        b = i
        while a > 0 and b > 0 and mine[a - 1] == ref[b - 1]:
            a -= 1
            b -= 1
        e = start + L
        f = i + L
        while e < len(mine) and f < len(ref) and mine[e] == ref[f]:
            e += 1
            f += 1
        key = (a, b)
        if anchors.get(key, 0) < e - a:
            anchors[key] = e - a
    runs = sorted((a, b, n) for (a, b), n in anchors.items())
    # merge overlapping/adjacent consistent runs
    merged = []
    for a, b, n in runs:
        if merged and a <= merged[-1][0] + merged[-1][2] and \
                a - merged[-1][0] == b - merged[-1][1]:
            m0 = merged[-1]
            merged[-1] = (m0[0], m0[1], max(m0[2], a + n - m0[0]))
        else:
            merged.append((a, b, n))
    return merged


def main():
    disasm = "--disasm" in sys.argv
    mine = load_mz(STUB_EXE)
    ref = load_mz(REF_EXE)
    print(f"stub image {len(mine)}, reference image {len(ref)}")

    mods, syms = parse_map()
    print("modules (my image):", [(n, hex(b), hex(sz)) for n, b, sz in mods])

    runs = align(mine, ref)
    print(f"{len(runs)} aligned runs, total matched {sum(r[2] for r in runs)}")
    for a, b, n in runs[:40]:
        print(f"  my {a:05X} -> ref {b:05X}  len {n}")

    # module base candidates: for each module symbol base, find my->ref mapping
    modmap = {}
    for a, b, n in runs:
        for name, mbase, msz in mods:
            for off in range(0, 1):
                pass
    # build monotone lookup: my_off -> ref_off from runs
    def to_ref(my):
        for a, b, n in runs:
            if a <= my < a + n:
                return b + (my - a)
        return None

    print("\n--- module bases in reference ---")
    refbase = {}
    for name, mbase, msz in mods:
        r = to_ref(mbase)
        refbase[name] = r
        print(f"{name:12s} my {mbase:05X} -> ref {'?' if r is None else format(r, '05X')} size {msz}")

    # fixup clusters: diff within aligned runs
    print("\n--- diff clusters (candidate fixups) ---")
    clusters = []
    for a, b, n in runs:
        i = 0
        while i < n:
            if mine[a + i] != ref[b + i]:
                j = i
                while j < n and mine[a + j] != ref[b + j]:
                    j += 1
                clusters.append((a + i, b + i, j - i))
                i = j
            else:
                i += 1
    print(f"{len(clusters)} clusters, total {sum(c[2] for c in clusters)} differing bytes")

    # symbol recovery: cluster at my offset X (2 bytes) -> value in ref
    rec = {}
    for myoff, refoff, ln in clusters:
        if ln != 2:
            continue
        val = struct.unpack_from("<H", ref, refoff)[0]
        rel = False
        if myoff >= 2 and mine[myoff - 2] in (0xE8, 0xE9):
            rel = True
        elif myoff >= 1 and mine[myoff - 1] in (0xE8, 0xE9):
            rel = True
        tgt = refoff + val + 2 if rel else val
        rec.setdefault(tgt, []).append(myoff)
    print("\n--- recovered targets (in reference) referenced from known code ---")
    for t in sorted(rec):
        n = len(rec[t])
        flag = " <== MISSING-SYM target" if any(
            s in syms and False for s in []) else ""
        print(f"{t:04X}  from {n} sites")

    # which clusters correspond to which of my stub symbols?
    print("\n--- stub symbol -> reference value ---")
    myval = {}
    for myoff, refoff, ln in clusters:
        if ln != 2:
            continue
        val = struct.unpack_from("<H", ref, refoff)[0]
        rel = (myoff >= 2 and mine[myoff - 2] in (0xE8, 0xE9)) or \
              (myoff >= 1 and mine[myoff - 1] in (0xE8, 0xE9))
        tgt = refoff + val + 2 if rel else val
        # find stub symbol equal to my resolved value
        myv = struct.unpack_from("<H", mine, myoff)[0]
        myt = myoff + myv + 2 if rel else myv
        names = [s for s, o in syms.items() if o == myt]
        if names or myt is None:
            pass
        myval.setdefault((myt, tgt), set()).update(names)
    for (myt, tgt), names in sorted(myval.items()):
        if names:
            print(f"{','.join(sorted(names)):20s} stub@{myt:04X} -> ref {tgt:04X}")

    # uncovered reference regions (not spanned by any aligned run)
    print("\n--- reference coverage ---")
    cov = bytearray(len(ref))
    for a, b, n in runs:
        for k in range(b, b + n):
            cov[k] = 1
    i = 0
    gaps = []
    while i < len(ref):
        j = i
        while j < len(ref) and cov[j] == cov[i]:
            j += 1
        if not cov[i]:
            gaps.append((i, j))
            print(f"UNCOVERED ref {i:05X}-{j-1:05X} ({j-i})")
        i = j

    if disasm and gaps:
        from capstone import Cs, CS_ARCH_X86, CS_MODE_16
        md = Cs(CS_ARCH_X86, CS_MODE_16)
        md.skipdata = True
        out = []
        rev = {o: s for s, o in syms.items()}
        for a, b in gaps:
            out.append(f"; ===== UNCOVERED ref {a:04X}-{b-1:04X} =====")
            for ins in md.disasm(bytes(ref[a:b]), a):
                extra = ""
                m = re.search(r"(0x[0-9a-f]+)$", ins.op_str)
                if ins.mnemonic in ("call", "jmp") or ins.mnemonic.startswith("j"):
                    t = int(m.group(1), 16) if m else None
                    if t is not None and t in rev:
                        extra = f"   ; -> {rev[t]}"
                out.append(f"{ins.address:04X}  {ins.bytes.hex():<18s} {ins.mnemonic:<7s} {ins.op_str}{extra}")
        (BUILD / "gap_disasm.txt").write_text("\n".join(out))
        print(f"wrote build/gap_disasm.txt ({len(out)} lines)")


if __name__ == "__main__":
    main()
