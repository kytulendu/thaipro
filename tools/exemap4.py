#!/usr/bin/env py
"""Chain-of-runs alignment of each module against the reference EXE.

For every code run (>=8 bytes, no fixups, no holes) find all occurrences in
the reference image, then build the longest increasing chain of anchors
(listing offset vs reference offset).  Handles 1991<->1992 drift by allowing
the chain to break between segments.  Then recover missing-symbol addresses
from fixups that fall inside chained segments only.

Usage: py exemap4.py [--disasm gapstart gapend ...]
"""
import re
import struct
import sys
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent
BUILD = REPO / "build"
sys.path.insert(0, str(REPO / "tools"))
import exemap2 as ex  # reuse listing parser

MISSING = ["CRT_MODE", "INDEXPORT", "OLDPAGE", "NEWPAGE", "CURSORLEVEL",
           "NEWVISIT", "CURPOINT", "RWOFFSET", "SAHAOFFSET", "ITAOFFSET",
           "ENGLISHMODE", "CLSCREEN", "CLSCREENODD", "CLSCREENORG", "SETMODE",
           "HARDCUR", "TRANSCURPOS", "INCODE5", "INCODE6", "INCODE7",
           "INCODE52", "OFFSETCODE2", "PROTECT_A000H"]


def code_runs(mod, minlen=10, step=8):
    """Yield (off, bytes) sliding code-only windows (fixup-free, hole-free)."""
    data = mod["data"]
    mask = mod["codelines"]
    fixes = set(mod["fixes"])
    n = min(len(data), len(mask))
    out = []
    i = 0
    while i + minlen <= n:
        if all(mask[k] and k not in fixes for k in range(i, i + minlen)):
            out.append((i, data[i : i + minlen]))
            i += step
        else:
            i += 1
    return out


def chain_anchors(runs, img):
    """Each window -> occurrences; build best increasing chain (DP)."""
    anchors = []
    for off, r in runs:
        occ = []
        i = img.find(r)
        while i >= 0 and len(occ) < 8:
            occ.append(i)
            i = img.find(r, i + 1)
        if len(occ) == 8:
            continue  # ambiguous/repetitive window
        for o in occ:
            anchors.append((off, o, len(r)))
    if not anchors:
        return []
    # DP: longest chain with strictly increasing off and ref off
    anchors.sort(key=lambda a: (a[0], a[1]))
    best = [1] * len(anchors)
    prev = [-1] * len(anchors)
    for i, (o1, r1, l1) in enumerate(anchors):
        for j in range(i):
            o2, r2, l2 = anchors[j]
            if o2 < o1 and r2 < r1:
                score = best[j] + min(l1, o1 - o2)
                if score > best[i]:
                    best[i] = score
                    prev[i] = j
    # backtrack best end
    endi = max(range(len(anchors)), key=lambda i: best[i])
    chain = []
    k = endi
    while k != -1:
        chain.append(anchors[k])
        k = prev[k]
    chain.reverse()
    # merge into segments with consistent delta
    segs = []
    for o, r, l in chain:
        d = r - o
        if segs and segs[-1]["d"] == d and o <= segs[-1]["end"]:
            segs[-1]["end"] = o + l
        else:
            segs.append({"start": o, "end": o + l, "d": d})
    return segs


def main():
    ref = ex.load_mz(ex.REF_EXE)
    img = ref["img"]
    symmap = {}
    allsegs = {}
    for name in ex.MODULES:
        mod = ex.build_module(name)
        runs = code_runs(mod)
        segs = chain_anchors(runs, img)
        allsegs[name] = segs
        total = sum(s["end"] - s["start"] for s in segs)
        print(f"{name:8s} runs={len(runs):4d} chain={len(segs):3d} segments, "
              f"matched {total:5d} bytes: " +
              " ".join(f"[{s['start']:04X}+{s['end']-s['start']:04X}@+{s['d']}]" for s in segs[:6]))
        # symbol recovery from fixups inside chained segments
        for grp in mod["fixgroups"]:
            sites = sorted(grp["sites"])
            names = grp["names"]
            if not names:
                continue
            pairs = (list(zip(sites, names)) if len(sites) == len(names)
                     else [(sites[0], names[0])] if len(sites) == 1 else [])
            for pos, nm in pairs:
                seg = next((s for s in segs if s["start"] <= pos < s["end"]), None)
                if seg is None:
                    continue
                site = pos + seg["d"]
                if site + 2 > len(img):
                    continue
                val = struct.unpack_from("<H", img, site)[0]
                rel = grp["sites"][pos][1] == "r"
                tgt = site + val + 2 if rel else val
                symmap.setdefault(nm, {}).setdefault(tgt, []).append(name)

    print("\n--- symbol targets (chained regions only) ---")
    for nm, tgts in sorted(symmap.items()):
        flag = "  <== MISSING" if nm in MISSING else ""
        print(f"{nm:18s}: " + ", ".join(f"{t:04X}({','.join(set(m))})" for t, m in sorted(tgts.items())) + flag)

    # reference coverage by chained segments
    cov = bytearray(len(img))
    for name, segs in allsegs.items():
        for s in segs:
            for k in range(s["start"], min(s["end"], len(img))):
                cov[k] = 1
    print("\n--- reference coverage (chained) ---")
    i = 0
    while i < len(img):
        j = i
        while j < len(img) and cov[j] == cov[i]:
            j += 1
        if not cov[i] and j - i >= 16:
            print(f"UNCOVERED {i:05X}-{j-1:05X} ({j-i})")
        i = j

    (BUILD / "symmap.json").write_text(__import__("json").dumps(
        {nm: {f"{t:04X}": sorted(set(m))} for nm, tgts in symmap.items()
         for t, m in tgts.items()}))


if __name__ == "__main__":
    main()
