# ThaiPro (Powersoft Thai Professional EGA/VGA 3.10) — rebuildable source

Partial recovered source of the **Powersoft Thai Professional EGA/VGA 3.10**
DOS Thai keyboard/video/printer driver, completed so that it **builds into a
working `THAIPRO.EXE`** (52,610 bytes vs. the shipped 52,146-byte binary from
Nov 1991).

```
dist\THAIPRO.EXE   <- ready-built driver
build.bat          <- one-shot build (JWasm + JWlink, both in tools\)
src\
  INSTALL.ASM      installer/TSR loader + embedded font banks (completed)
  INT9.ASM         keyboard hook (Thai key translation)
  INT8.ASM         timer hook (screen refresh / cursor blink)
  INT10.ASM        video hook (shadow-page display logic)
  INT17.ASM        printer hook (Thai printer translation)
  INT60.ASM        hot-key / popup-menu dispatch
  MENU.ASM         popup menu + configuration tables
  GAP.ASM          RECONSTRUCTED video-support module (was missing entirely)
reference\         original distribution (THAIPRO.EXE Nov-1991, docs, utils)
tools\             JWasm/JWlink + analysis scripts used during recovery
```

## Build

```
build.bat
```
Requires only `tools\JWasm.exe` and `tools\JWlink.exe` (JWasm 2.20 / JWlink 2.0,
Sybase Open Watcom Public License, both bundled in `tools\`).  Output:
`dist\THAIPRO.EXE`.

Tested in DOSBox-X: `THAIPRO.EXE` installs the TSR, answers the driver
signature (`int 17h` `AH=50h` -> `AL=0EEh`), draws its popup menu
(`Ctrl+F1`), loads its fonts and renders Thai text.

## What was missing from the partial source, and how it was recovered

The recovered partial source (7 .ASM files) was "mostly complete" but
did not assemble/link.  Everything below was reconstructed against the
shipped `THAIPRO.EXE` (Nov 19 1991, in `reference\thaipro310\THAIPRO\`):

1. **`INSTALL.ASM` junk lines** — 30 lines containing a lone `.` (leftovers of
   removed line numbers) deleted.
2. **MASM 5 vs MASM 6 scoping** — labels defined inside a `PROC` were
   procedure-local in every module while other modules `EXTRN`-referenced
   them.  52 such labels were changed from `label:` to `label::` (module
   scope), and `OPTION PROC:PRIVATE` was added so JWasm doesn't export every
   procedure name (MASM 5 behaviour, which the duplicate names across modules
   rely on).
3. **`call cs:[bx]`** (4 sites) needed an explicit `WORD PTR` for JWasm.
4. **Case mapping** — the sources mix e.g. `Setmode`/`SetMode`; assembled with
   `-Cu` (MASM 5.1 default: uppercase all symbols).
5. **The whole "video support" module** (≈1.1 KB of code + data) was missing:
   `HardCur`, `TransCurpos`, `Clscreen`, `ClscreenOdd`, `ClscreenOrg`,
   `Setmode`, the per-mode parameter table `EnglishMode`, variables
   (`IndexPort`, `CRT_MODE`, `OldPage`, `NewPage`, `CursorLevel`, `CurPoint`,
   `NewVisit`) and the patchable instruction labels `INCODE5/6/7/52`,
   `OffsetCode2`, `PROTECT_A000H` that `INSTALL.ASM` rewrites at install time.
   All of it was disassembled from the shipped `THAIPRO.EXE` (region
   0x2F85–0x33E6 of the load image) and hand-transcribed into `src\GAP.ASM`
   (original offsets kept as comments).
6. **Font banks** — `INSTALL.ASM` embedded 10 font banks of 2048 bytes each
   but only the first 266 bytes of every bank survived.  The full banks were
   extracted from the shipped driver (font region starts at image offset
   0x7340; `EGAfont1=0x7340, EGAfont2=0x7B40, EGARWfont=0x8340, EGAsaha=0x8B40,
   EGAita=0x9340` — confirmed by the font pointers `INSTALL` writes at
   runtime).  **Note:** the 1992 fragment bytes in the partial source belong
   to a *different (newer) font set* and do not appear anywhere in the shipped
   binary, so the shipped 1991 font content is used for all ten banks; the
   five `VGA*` banks (whose 1992 content is lost) are filled with the EGA
   content so the install-time `VGAfont1 -> EGAfont1` copy is a no-op.

## Tooling notes (tools\)

* `fix_scope.py` — applies the `label:` -> `label::` fixes from JWasm error
  output (already applied to the sources; kept for reference).
* `exemap2.py`, `recover_syms.py` — module/base/symbol recovery against the
  reference binary (JWasm listing parsing; beware: JWasm listings print
  marked operands as values, not memory byte order).
* `exemap3.py`, `exemap4.py` — earlier/differential alignment experiments.

## Known differences from the shipped binary

* Assembled with JWasm/JWlink instead of MASM 5 + LINK: internal offsets and
  some short-jump displacements differ; size differs by ~460 bytes.
* `GAP.ASM` addresses its own variables relatively (same instructions,
  different absolute displacements).
* The five `VGA*` font banks contain EGA font content (see note above); on a
  VGA machine the install-time copy therefore keeps the EGA glyphs instead of
  restoring the lost 1992 VGA font drawings.
