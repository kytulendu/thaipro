#!/usr/bin/env py
"""Recover missing-symbol addresses from the reference EXE.

Module deltas determined by window-voting (see notes).  A fixup site is
trusted only when its 4-byte context (2 bytes before/after) matches the
reference at base+pos, proving the instruction is identical there.

Usage: py recover_syms.py
"""
import struct
import sys
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent
BUILD = REPO / "build"
sys.path.insert(0, str(REPO / "tools"))
import exemap2 as ex

DELTAS = {"INT8": 0x0, "INT9": 0x70A, "INT10": 0xAC1, "INT17": 0x165A,
          "INT60": 0x2A30, "MENU": 0x33E6}

MISSING = ["CRT_MODE", "INDEXPORT", "OLDPAGE", "NEWPAGE", "CURSORLEVEL",
           "NEWVISIT", "CURPOINT", "RWOFFSET", "SAHAOFFSET", "ITAOFFSET",
           "ENGLISHMODE", "CLSCREEN", "CLSCREENODD", "CLSCREENORG", "SETMODE",
           "HARDCUR", "TRANSCURPOS", "INCODE5", "INCODE6", "INCODE7",
           "INCODE52", "OFFSETCODE2", "PROTECT_A000H"]


def main():
    ref = ex.load_mz(ex.REF_EXE)
    img = ref["img"]
    symmap = {}
    for name, delta in DELTAS.items():
        mod = ex.build_module(name)
        data = mod["data"]
        for grp in mod["fixgroups"]:
            sites = sorted(grp["sites"])
            names = grp["names"]
            if not names:
                continue
            pairs = (list(zip(sites, names)) if len(sites) == len(names)
                     else [(sites[0], names[0])] if len(sites) == 1 else [])
            for pos, nm in pairs:
                site = delta + pos
                if site < 2 or site + 4 > len(img):
                    continue
                # context check: 2 bytes before and after must match
                if (img[site - 2:site] != data[pos - 2:pos] or
                        img[site + 2:site + 4] != data[pos + 2:pos + 4]):
                    continue
                val = struct.unpack_from("<H", img, site)[0]
                rel = grp["sites"][pos][1] == "r"
                tgt = site + val + 2 if rel else val
                symmap.setdefault(nm, {}).setdefault(tgt, []).append(name)

    print("--- all recovered symbol targets ---")
    for nm, tgts in sorted(symmap.items()):
        flag = "   <== MISSING-SYM" if nm in MISSING else ""
        print(f"{nm:18s}: " +
              ", ".join(f"{t:04X}({','.join(sorted(set(m)))})" for t, m in sorted(tgts.items())) + flag)


if __name__ == "__main__":
    main()
