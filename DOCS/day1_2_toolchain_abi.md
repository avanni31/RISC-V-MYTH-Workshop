# Day 1–2: RISC-V Toolchain, ISA & ABI

## 1. Instruction Set Architecture (ISA) — big picture

RISC-V architecture is a **specification**, later implemented in hardware via RTL. Applications running on a laptop/phone go through several software layers before touching hardware:

```
 Application (C, C++, Java, VB...)
          │
          ▼
   Operating System   → I/O handling, memory allocation, low-level system functions,
          │              converts app code into assembly + binary understood by hardware
          ▼
      Compiler         → converts C/C++/... operations into the Instruction Set
          │              (the ISA acts as the interface between language and hardware)
          ▼
      Assembler         → converts the instruction set into binary (machine code)
          │
          ▼
     RTL implementation → what actually runs on the hardware
```

### Pseudo-instructions & standard extensions covered
- **Base Integer Instructions — RV64I:** `mv`, `li`, `ret`, and instructions used to break values into parts.
- **Multiply Extension — RV64M:** `mulw`, `divw`
- **Single/Double precision floating point — RV64F & RV64D:** `fsd`, `flw`, `fmul.s`, `fdiv.s`, `fcvt.d.s`, `fmv.x.d`, `fld`, `fadd.s`

---

## 2. Application Binary Interface (ABI)

The ABI is how application code accesses hardware **registers directly** — e.g. `a0`, `sp`, `ra`, etc. It sits between the ISA (User & System, RISC-V/ARM/x86) and the hardware/RTL, and is also called the **System Call Interface**.

- **Memory allocation & stack pointer:** data is transferred from registers to memory, e.g. `sp, sp, -32`.
- A 64-bit integer is a **double word**; a 32-bit integer is a **word**.
- The last bit of a 32-bit value is the **MSB** (most significant bit); the first bit is the **LSB** (least significant bit).
- A group of 8 bits is a **byte**.
- For positive values, MSB = 0. For negative values, MSB = 1.

### Number representation on RV64
- Lowest **positive** representable number: MSB = 0, rest 0.
- Highest **positive** number: `9223372036854775807` (dec), MSB = 0, rest 1.
- Lowest **negative** number: `-9223372036854775808` (dec), MSB = 1, rest 0.
- Range: positive → `0` to `2^63 - 1`; negative → `-1` to `-2^63`.

*(Reference labs: RV-DISK2 → Full range, RV-DISK3 → Last value)*

### Registers & ABI names

| Register | ABI name | Usage | Saver |
|---|---|---|---|
| x0 | zero | Hard-wired zero | – |
| x1 | ra | Return address | Caller |
| x2 | sp | Stack pointer | Callee |
| x3 | gp | Global pointer | – |
| x4 | tp | Thread pointer | – |
| x5–x7 | t0–2 | Temporaries | Caller |
| x8 | s0/fp | Saved register / frame pointer | Callee |
| x9 | s1 | Saved register | Callee |
| x10–11 | a0–1 | Function arguments / return values | Caller |
| x12–17 | a2–7 | Function arguments | Caller |
| x18–27 | s2–11 | Saved registers | Callee |
| x28–31 | t3–6 | Temporaries | Callee |

All registers are addressed using **5 bits** (32 registers).

### Little-endian memory addressing
RISC-V uses **little-endian** memory addressing — storage starts from the LSB (as opposed to big-endian, which starts from the MSB).

- If the address of the 1st doubleword is `m[0]`, the 2nd is `m[8]`, the 3rd is `m[16]`, etc. (8-byte strides for doublewords).

### Load/Store instruction encoding

To load a doubleword from memory into register `x8`, given a base address stored in `x23`:

```asm
ld   x8, 16(x23)
```
- `ld` = load double word
- destination register `rd` = x8
- source register `rs1` = x23 (holds the base address)
- `16` = immediate offset, added to `x23` to form the final address

**I-type instruction encoding** (used by `ld`):
```
| immediate[31:20] | rs1[19:15] | funct3[14:12] | rd[11:7] | opcode[6:0] |
```
- All instructions are **32 bits** wide, for both RV32 and RV64 registers.
- Bits 0–6 = opcode, along with funct3.
- `rs1` = source register (5 bits).
- `rd` = destination register (5 bits).
- Bits 20–31 = the immediate value.

**R-type instruction encoding** (used by `add`), e.g. `add x8, x24, x8`:
```
| funct7[31:25] | rs2[24:20] | rs1[19:15] | funct3[14:12] | rd[11:7] | opcode[6:0] |
```
- Operates only on registers (no immediate).
- `rs1` = x24 (source 1), `rs2` = x8 (source 2), `rd` = x8 (destination).

**S-type instruction encoding** (used by `sd`), e.g. `sd x8, 8(x23)`:
```
| immediate[11:5] | rs2 | rs1 | funct3 | immediate[4:0] | opcode |
```
- Operates on a source register and an immediate, and also stores to memory. The immediate is split into two fields stored in different places within the instruction word.

---

## 3. Lab: C → RISC-V → Spike Workflow

1. **Write a C program:** `sum1ton.c`
2. **Compile for RV64 architecture:**
   ```bash
   riscv64-unknown-elf-gcc -O1 -mabi=lp64 -march=rv64i -o sum1ton.o sum1ton.c
   ```
3. **View the generated assembly** (C-language view):
   ```bash
   riscv64-unknown-elf-objdump -d sum1ton.o
   ```
4. **Disassemble and search for `main`:**
   ```bash
   riscv64-unknown-elf-objdump -d sum1ton.o | less
   # search: /main   -> 15 instructions found
   ```
   `main`'s address increments by 4 per instruction. Counted the number of instructions to illustrate the first group, starting at `main`'s first address.

5. **Re-run with `-Ofast`** to compare instruction count:
   ```bash
   riscv64-unknown-elf-gcc -O1 -mabi=lp64 -march=rv64i -Ofast -o sum1ton.o sum1ton.c
   riscv64-unknown-elf-objdump -d sum1ton.o | less
   ```
   Re-running `main` under `-Ofast` showed **12 instructions** (down from 15) — next up: **debugging**.

6. **Run on the Spike simulator** and compare against direct execution:
   ```bash
   spike pk sum1ton.o
   ```
   Output verified to be `55` (sum of 1 to 10).

   Then, to run **without** using the RISC-V toolchain (native execution, for comparison):
   ```bash
   gcc sum1ton.c   # produces a.out
   ./a.out
   ```
   Both outputs matched — verifying that the RISC-V simulation is running correctly.

7. **Disassemble again for debugging:**
   ```bash
   riscv64-unknown-elf-objdump -d sum1ton.o | less
   ```

8. **Debug with Spike's built-in debugger:**
   ```bash
   spike -d pk sum1ton.o
   ```
   - Run until the PC reaches a certain point:
     ```
     until pc 0 100b0
     ```
   - Inspect the content of register `a2`:
     ```
     reg 0 a2
     ```
   - Press **Enter** to run the next instruction (e.g. `lui a2, 0x1`), then re-inspect the register to see it's modified:
     ```
     reg 0 a2
     ```
   - Repeated this pattern (`lui a0, 0x21` → `reg 0 a0` → confirm modification) to step through execution.

---

## 4. Lab: Writing RISC-V Assembly by Hand (ASM ↔ C linkage)

Arguments from a C program are passed to hand-written assembly in **two registers**, and a result is returned in **only one register**.

### Algorithm: Sum 1 to N (illustrated via flowchart)

```
Main C program ──a0=0, a1=10──► Start
                                   │
                          Initialize a4 with "zero"
                                   │
                          Initialize a3 with "zero"
                                   │
                          Store count "10" in a2
                                   │
                     ┌──────────► a4 = a3 + a4
                     │             │
                    yes          a3 = a3 + 1
                     │             │
                     └────── Is a3 < a2 ?
                                   │ no
                             a0 = a4 + zero
                                   │
Main C program ◄────Return a0──── End
```

### Steps
1. Create `1to9_custom.c` and `load.s` (hand-written RISC-V assembly).
2. Compile & link:
   ```bash
   riscv64-unknown-elf-gcc -Ofast -mabi=64 -march=rv64i \
     -o 1to9_custom.o 1to9_custom.c load.s
   ```
3. Run on Spike:
   ```bash
   spike pk 1to9_custom.o
   ```
   → Output: sum of `1..9` = **45**.
4. Disassemble to inspect the RISC-V architecture output:
   ```bash
   riscv64-unknown-elf-objdump -d 1to9_custom.o | less
   ```

This closes the toolchain loop: **C → hand-written/compiled assembly → RISC-V machine code → Spike simulation**, before moving on to actually building a RISC-V CPU in TL-Verilog (Days 3–5).
