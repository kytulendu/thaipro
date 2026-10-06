# ThaiPro — Powersoft Thai Professional EGA/VGA 3.10 (rebuildable source)

**English summary**

Rebuildable source of *Powersoft Thai Professional EGA/VGA 3.10*, a 1991 DOS
Thai keyboard/video/printer TSR driver. The partial source received from the
original developer (`INSTALL INT9 INT8 INT10 INT17 INT60 MENU`) did not
build; the missing video module (`GAP.ASM`) was written by disassembling the
shipped `THAIPRO.EXE` (Nov 1991), and the received files were minimally
corrected (fonts, tables, default settings, two bugs) until the rebuilt
driver behaves like the shipped one in DOSBox-X (Thai fonts, screen
scroll/clear, cursor, popup menu). Build with `build.bat` (JWasm 2.20 +
JWlink 2.0 bundled in `tools\`, Windows). Output: `dist\THAIPRO.EXE`
(51,314 bytes vs 52,146 for the shipped binary; the logo text differs).
Details below, in Thai.

---

## โครงสร้าง

```
dist\THAIPRO.EXE   ไดรเวอร์ที่ build แล้ว (สร้างโดย build.bat)
build.bat          สั่ง build ในคำสั่งเดียว (JWasm + JWlink)
link.rsp           คำสั่งลิงก์
src\
  INSTALL.ASM      ตัวติดตั้ง/โหลด TSR + ฟอนต์ทั้งหมด
  INT9.ASM         hook คีย์บอร์ด (แปลงแป้นพิมพ์ไทย)
  INT8.ASM         hook timer (refresh จอ, cursor)
  INT10.ASM        hook วิดีโอ (จอแบบ shadow page)
  INT17.ASM        hook เครื่องพิมพ์ (แปลงรหัสไทย)
  INT60.ASM        hotkey / เมนูป๊อปอัป
  MENU.ASM         เมนู + ตารางค่าตั้ง
  GAP.ASM          โมดูลวิดีโอที่เขียนขึ้นใหม่ (ต้นฉบับขาดหายไป)
tools\             JWasm.exe, JWlink.exe และ License.txt (ใบอนุญาต Sybase Open Watcom)
```

## วิธี build

```
build.bat
```
ใช้เฉพาะ `tools\JWasm.exe` และ `tools\JWlink.exe` (Windows) ผลลัพธ์อยู่ที่
`dist\THAIPRO.EXE` ทดสอบใน DOSBox-X (VGA): ติดตั้ง TSR ได้, แสดงโลโก้,
ฟอนต์ไทย 3 ระดับถูกต้อง, จอเลื่อน/ลบได้, cursor ขยับ, เมนูแสดงไทยถูกต้อง
ต่างจากตัวเดิมที่โลโก้เท่านั้น (ชื่อผู้จัดทำในซอร์สไม่เหมือนกัน)

## ที่มาของไฟล์

| ไฟล์ | ที่มา |
|------|-------|
| `INSTALL`, `INT9`, `INT8`, `INT10`, `INT17`, `INT60`, `MENU` | ซอร์สบางส่วนที่ได้จากผู้พัฒนา (รุ่นหลัง/ปี 1992) แก้ไขตามรายการด้านล่างเท่านั้น |
| `GAP.ASM` | **เขียนใหม่** จากการ disassemble `THAIPRO.EXE` ปี 1991 (โมดูลนี้ไม่มีในซอร์สที่ได้รับ) |

## `GAP.ASM` ทำหน้าที่อะไร (โมดูลสนับสนุนวิดีโอ)

* `HardCur` — อ่านตำแหน่ง cursor จาก CRTC (0Eh/0Fh) แปลงเป็นต้นแถว แล้วเรียก `TransCurpos`
* `TransCurpos` — เดินทีละแถวของ shadow screen (`B800`) แยกอักขระไทยเป็นระดับ
  ตัวหลัก / บน / ล่าง ด้วยตารางแปลงรหัส เขียนลงหน้าจอที่ประกอบแล้ว
  และตั้ง start address กับตำแหน่ง cursor ของ CRTC ใหม่ (มีคำสั่งที่ตัวติดตั้งแก้ตอน install
  คือ `cmp al,20h` = `OffsetCode2` และกลุ่ม INCODE)
* `SetCurShape` — ตั้งรูปทรง cursor (CRTC 0Ah/0Bh) จาก `CursorLevel`; ถูกเรียกจาก INT 10h AH=1
* `Setmode` — ตามโหมดปัจจุบัน (ตาราง `EnglishMode` โหมดละ 15 ไบต์) ตั้ง CRTC
  (ความสูงตัวอักษร ฯลฯ), โหลดฟอนต์ผ่าน `FontLoad` (ASCII จาก ROM, ภาษาไทยที่ 80h–FFh;
  โหมด 1/2 เลือกชุด RW/OEM, SAHA/TIS, ITA ผ่าน `FontPtrV1/V2/V3`) และล้างหน้าจอ
* `FontLoad` / `SeqWrite` — เขียนฟอนต์ลง font RAM (plane 2) ผ่าน sequencer /
  graphics controller ตามตารางรีจิสเตอร์ `FontSeqTab`, `PROTECT_A000H`
* `Clscreen`, `ClscreenOdd`, `ClscreenOrg` — ล้าง shadow page / หน้าคี่ / หน้าจอที่มองเห็น
* ตัวแปรวิดีโอ: `EnglishMode`, `IndexPort`, `CRT_MODE`, `OldPage`, `NewPage`,
  `CursorLevel`, `CurPoint`, `RWoffset/SAHAoffset/ITAoffset` ที่ `INSTALL` แก้ค่าตอนติดตั้ง

## สิ่งที่แก้ในซอร์สที่ได้รับ

เพื่อให้ assemble ด้วย JWasm/JWlink ได้:

1. `INSTALL.ASM`: ลบบรรทัดขยะ (จุด `.` เดี่ยว ๆ) 30 บรรทัด
2. ทุกโมดูล: label ที่เป็น local ของ PROC แต่ถูกโมดูลอื่นอ้าง 52 จุด เปลี่ยน
   `label:` เป็น `label::` และเพิ่ม `OPTION PROC:PRIVATE` (พฤติกรรม scope แบบ MASM 5);
   `call cs:[bx]` 4 จุดเติม `WORD PTR`; assemble ด้วย `-Cu` (สัญลักษณ์ตัวพิมพ์ใหญ่แบบ MASM 5.1)

เพื่อให้ทำงานเหมือนตัวที่แจกจริง:

3. `INSTALL.ASM`
   * ฟอนต์: ซอร์สเหลือเพียง 266 ไบต์แรกของแต่ละ bank จึงกู้ใหม่จาก EXE เดิม:
     EGA 5 bank ๆ ละ 0x700 ไบต์ (14 scan line × 128 ตัว) และ VGA 5 bank ๆ ละ 0x800 ไบต์
     (16 line) บนการ์ด VGA ตัวติดตั้งจะคัดลอก bank VGA ทับ `EGAfont1`
   * ขนาดที่ TSR ค้างในหน่วยความจำ: ตัวจริงใช้ `(LimitDown+15)/16 + 100h` paragraph
     (เผื่อเพิ่ม 4 KB) แต่ซอร์สใช้ `+10h` — แก้ให้ตรง
4. `INT10.ASM`: handler ของ INT 10h AH=1 เรียก `TransCurpos` ผิดตัว ตัวจริงเรียก
   ฟังก์ชันตั้งรูปทรง cursor (`SetCurShape`) — แก้แล้ว (อาการ cursor ค้างที่คอลัมน์ 1)
5. `INT8.ASM`: เขียนตารางแปลงรหัส `TableTIS`, `KU_TIS`, `TIS_KU`, `TIS_SCT`, `SCT_TIS`
   ใหม่จาก EXE เดิม
6. `MENU.ASM`: ปรับค่าเริ่มต้นให้ตรงตัว 1991 — ตาราง dispatch ของ INT 10h เริ่มที่
   `OldVDOReturn`, `RefrOnOff=0`, `TimerRun=L_refresh1`, `CurrMode/KeyMode/CurrMode1=3`,
   ปุ่มสลับภาษาเป็น `~` (scan 29h, ข้อความเมนู "Key ~"), แถบสถานะ `CornerET`,
   ค่า line spacing/printer (`Spacing*`, `Hex72/Hex216`), สีแถบ, `CornerPos`, ฟอนต์ตัวหนา

วิธีหาจุดผิด: เทียบไบต์ที่ตัวติดตั้งแก้ในหน่วยความจำ แล้วจำลองการทำงานระดับคำสั่ง
(Unicorn) ของตัวติดตั้ง, INT 8 refresh และเมนูของทั้งสองไบนารี เทียบ log พอร์ต CRTC และ font RAM

## ความต่างที่ยังเหลือเทียบกับตัวจริง

* JWasm/JWlink แทน MASM 5 + LINK: การเข้ารหัสบางคำสั่ง (NOP padding, short jump)
  ต่างกัน ไฟล์เล็กกว่า 832 ไบต์ และ offset เลื่อน 0x10–0x20
* ข้อความโลโก้ (ชื่อผู้จัดทำ) ต่างกัน
* padding ของตาราง escape เครื่องพิมพ์ (0FFh) และค่า attribute `COLOR5` (7Ch กับ 78h) ต่างกัน
  ไม่มีผลต่อหน้าจอ
