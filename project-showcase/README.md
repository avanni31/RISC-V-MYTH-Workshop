# Project Showcase — Pipelined RISC-V CPU

## From Labs to a Processor

The central outcome of the five-day workshop was the progressive construction of a RISC-V processor.

The project can be summarized as:

```text
RISC-V fundamentals
       ↓
Instruction encoding
       ↓
Digital logic
       ↓
TL-Verilog
       ↓
CPU datapath
       ↓
Instruction decode
       ↓
Control flow
       ↓
Pipelining
       ↓
Hazard handling
       ↓
Verification
```

## Final Project

A pipelined RISC-V CPU implemented using TL-Verilog in the Makerchip-oriented workshop environment.

### Core blocks

- Program Counter
- Instruction Memory
- Instruction Decode
- Immediate Generator
- Register File
- ALU
- Branch Logic
- Data Memory
- Writeback
- Pipeline Validity
- Bypass / Forwarding
- Load Replay

## Why the project is significant

The earlier labs directly feed the final architecture:

| Workshop exercise | Where it appears in the CPU |
|---|---|
| Logic gates | Decode and control |
| MUX | Next-PC/result selection |
| Vectors | 32-bit datapath |
| State | PC and architectural state |
| Sequential calculator | Stateful computation |
| Pipeline exercises | CPU stage structure |
| Validity | Pipeline control |
| RISC-V decode | Instruction control |
| ALU | Execute stage |
| Memory exercises | Load/store |
| Bypass | Data-hazard resolution |

## End-to-End Demonstration

The workshop test program calculates:

```text
1 + 2 + 3 + 4 + 5 + 6 + 7 + 8 + 9 = 45
```

The final CPU uses this as an integrated functional check.

## Files

- [`../day-05-pipelined-risc-v/final_cpu.tlv`](../day-05-pipelined-risc-v/final_cpu.tlv) — final saved CPU source
- [`architecture.md`](architecture.md) — architecture explanation
- [`verification.md`](verification.md) — verification strategy
- [`learning-outcomes.md`](learning-outcomes.md) — skills developed
