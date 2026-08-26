# Day 2 — ISA Encoding and CPU Preparation

## 1. Instruction structure

RISC-V instructions are fixed-width 32-bit instructions in the RV32I context used by the workshop.

The major formats encountered in the notes are:

- R-type
- I-type
- S-type
- B-type
- U-type
- J-type

## 2. Core instruction fields

The CPU decode stage needs fields such as:

- `opcode`
- `funct3`
- `funct7`
- `rs1`
- `rs2`
- `rd`
- `imm`

These fields do not occupy identical bit positions in every instruction format, so immediate generation is part of the decode logic.

## 3. Immediate generation

The CPU forms a 32-bit immediate according to instruction type.

Conceptually:

```text
I-immediate → sign extension of instr[31:20]
S-immediate → instr[31:25] + instr[11:7]
B-immediate → branch-specific scattered fields + low zero bit
U-immediate → upper instruction fields + 12 low zeros
J-immediate → jump-specific scattered fields + low zero bit
```

## 4. Decode strategy

The workshop uses a combination of instruction-type detection and field matching. A useful abstraction is:

```text
instruction
    ↓
type decode
    ↓
field extraction
    ↓
specific instruction decode
    ↓
control / ALU / branch / memory behavior
```

## 5. CPU datapath preparation

The notes introduce the core blocks used later:

- Program counter
- Instruction memory
- Decoder
- Register-file read
- ALU
- Register-file write
- Data memory
- Branch target logic

## 6. Key takeaway

Day 2 connects the abstract ISA to the actual wires and control signals that a processor implementation needs.
