# Day 1 — RISC-V Fundamentals

## 1. What is an ISA?

A processor instruction-set architecture defines the interface between software and hardware. The supplied notes describe RISC-V as an open instruction-set architecture whose instructions are ultimately implemented by hardware.

The software-to-hardware flow covered in the notes can be summarized as:

```text
Application
    ↓
Operating system / libraries
    ↓
Compiler
    ↓
Assembly
    ↓
Machine code
    ↓
Hardware implementation
```

## 2. RISC-V instruction categories

The notes introduce:

- Base integer instructions
- Pseudoinstructions
- Multiply/divide extensions
- Single/double precision floating-point extensions
- Compressed instructions
- ABI conventions

## 3. Integer widths

The notes distinguish:

- 64-bit integer / doubleword
- 32-bit integer / word
- 16-bit halfword
- 8-bit byte

The supplied notes also explain that RISC-V can use different register widths depending on the ISA variant.

## 4. Signed and unsigned representation

The notes discuss signed representation and sign extension, including the role of the most significant bit for signed values.

## 5. ABI register conventions

Important ABI names documented in the notes include:

| Register | ABI name | Typical role |
|---|---|---|
| x0 | zero | Hard-wired zero |
| x1 | ra | Return address |
| x2 | sp | Stack pointer |
| x3 | gp | Global pointer |
| x4 | tp | Thread pointer |
| x5–x7 | t0–t2 | Temporaries |
| x8 | s0/fp | Saved register / frame pointer |
| x9 | s1 | Saved register |
| x10–x11 | a0–a1 | Arguments / return values |
| x12–x17 | a2–a7 | Function arguments |
| x18–x27 | s2–s11 | Saved registers |
| x28–x31 | t3–t6 | Temporaries |

## 6. Memory representation

The notes emphasize that RISC-V belongs to a little-endian memory-addressing system. A multi-byte value is stored across increasing byte addresses, with the least-significant byte at the lowest address.

## 7. Key takeaway

Day 1 establishes the software-visible contract that the CPU being built later must implement.
