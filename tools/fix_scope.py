#!/usr/bin/env py
"""Fix MASM5-style PROC-internal labels that JWasm (MASM6 scoping) hides.

Reads JWasm error output, for every "Symbol not defined : sym" at file:line,
if `sym:` is defined inside a PROC block in that same file, change that
definition to `sym::` (module scope). Repeat externally until clean.

Usage: py fix_scope.py <errfile...>
"""
import re
import sys
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent
ERR_RE = re.compile(r'^(.*?)\((\d+)\)\s*:\s*Error A2102: Symbol not defined\s*:\s*(\S+)')
LABEL_RE = re.compile(r'^(\s*)([A-Za-z_$?@][\w$?@]*):(\s|$)')


def proc_spans(lines):
    spans, cur = [], None
    for i, ln in enumerate(lines):
        s = ln.strip()
        if cur is None:
            if re.search(r'\bPROC\b', s, re.I):
                cur = i
        elif re.search(r'\bENDP\b', s, re.I):
            spans.append((cur, i))
            cur = None
    if cur is not None:
        spans.append((cur, len(lines)))
    return spans


def main():
    fixed = {}
    for errfile in sys.argv[1:]:
        for line in Path(errfile).read_text(errors='replace').splitlines():
            m = ERR_RE.match(line)
            if not m:
                continue
            src, lineno, sym = m.group(1), int(m.group(2)), m.group(3)
            path = REPO / src
            if not path.exists():
                continue
            text = path.read_bytes().decode('latin-1')
            lines = text.splitlines(keepends=True)
            spans = proc_spans(lines)
            for i, ln in enumerate(lines):
                lm = LABEL_RE.match(ln)
                if lm and lm.group(2) == sym and any(a <= i < b for a, b in spans):
                    lines[i] = f'{lm.group(1)}{sym}::{lm.group(3)}' + ln[lm.end():]
                    path.write_bytes(''.join(lines).encode('latin-1'))
                    fixed.setdefault(str(path), []).append((i + 1, sym))
                    break
    for path, items in fixed.items():
        for lineno, sym in items:
            print(f'{path}({lineno}): {sym}: -> {sym}::')
    print(f'total fixed: {sum(len(v) for v in fixed.values())}')


if __name__ == '__main__':
    main()
