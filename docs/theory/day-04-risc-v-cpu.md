# Day 4 — Coding a RISC-V CPU Subset

The Day 4 sequence builds the CPU datapath incrementally.

## 1. Next PC

The first CPU lab implements:

```text
reset → PC = 0
normal operation → PC = PC + 4
```

The supplied workshop slide specifies checking the simulated PC sequence as `0, 4, ...`.

## 2. Instruction Fetch

Instruction memory is connected to the PC. The memory interface uses:

- read enable
- read address
- 32-bit instruction data

The instruction is read using the appropriate PC bits as the instruction-memory index.

## 3. Instruction type decode

The decoder identifies:

- I
- R
- S
- B
- J
- U

instruction types from instruction bits.

## 4. Immediate decode

The CPU generates a 32-bit immediate according to the instruction type.

## 5. Instruction field decode

The CPU extracts:

- opcode
- funct3
- funct7
- rs1
- rs2
- rd

and also generates validity signals for fields that exist for each instruction class.

## 6. Instruction decode

The workshop then matches decoded fields to individual RV32I instructions.

## 7. ALU

The ALU initially implements ADD/ADDI and is progressively extended.

The final integrated source in this portfolio includes arithmetic, logical, shift, comparison, upper-immediate, PC-relative and jump-related result cases.

## 8. Register-file write

The register-file write interface is connected to the decoded destination register and ALU result.

RISC-V `x0` remains hard-wired to zero and should not be overwritten.

## 9. Branches

The branch logic determines:

- branch target
- whether the branch is taken

The supported branch conditions include:

- BEQ
- BNE
- BLT
- BGE
- BLTU
- BGEU

## 10. Testbench

The workshop testbench checks the final accumulated result in register `x10`, with the expected sum:

```text
1 + 2 + ... + 9 = 45
```
