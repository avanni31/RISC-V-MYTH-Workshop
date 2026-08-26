# RISC-V MYTH Workshop — 5-Day Hardware Design Portfolio

> **A five-day hands-on journey from RISC-V fundamentals and digital logic to a pipelined RISC-V CPU using TL-Verilog and Makerchip.**

This repository documents my complete work from a five-day RISC-V/MYTH workshop. It is organized as a **learning journey and engineering portfolio**, not just a collection of lab answers.

The work progressed from understanding how a RISC-V processor is defined and how instructions are represented, through digital logic and TL-Verilog, and finally into the implementation, pipelining, hazard handling and verification of a RISC-V CPU.

---

## Table of Contents

- [About the Workshop](#about-the-workshop)
- [My Five-Day Learning Journey](#my-five-day-learning-journey)
- [Final Project — Pipelined RISC-V CPU](#final-project--pipelined-risc-v-cpu)
- [What I Implemented](#what-i-implemented)
- [Verification](#verification)
- [Tools and Technologies](#tools-and-technologies)
- [Repository Structure](#repository-structure)
- [Skills Developed](#skills-developed)
- [Evidence and Reference Material](#evidence-and-reference-material)
- [Acknowledgements](#acknowledgements)

---

# About the Workshop

The workshop introduced the design of a processor from the ground up, starting with the fundamentals required to understand a RISC-V CPU and progressing into actual hardware implementation.

The overall progression was:

```text
RISC-V ISA
    ↓
Instruction formats / ABI / memory
    ↓
Digital logic
    ↓
TL-Verilog + Makerchip
    ↓
Sequential logic + state
    ↓
Pipelining concepts
    ↓
RISC-V CPU datapath
    ↓
Instruction decoding
    ↓
ALU + Register File
    ↓
Branches + Memory
    ↓
Pipeline validity
    ↓
Hazards + Bypassing
    ↓
Load Replay
    ↓
Final CPU + Verification
```

The supplied workshop material divides the implementation-oriented portion into Day 3 (digital logic/TL-Verilog), Day 4 (coding a RISC-V CPU subset), and Day 5 (pipelining and completing the CPU).

---

# My Five-Day Learning Journey

## Day 1 — RISC-V Fundamentals

The first day established the foundation for everything that followed.

I worked through the relationship between software and the processor and learned how an ISA defines the instructions and architectural behavior visible to software.

### Topics covered

- RISC-V instruction-set architecture
- Base integer instructions
- Instruction extensions
- Pseudoinstructions
- Compiler / assembler / machine-code flow
- Integer widths
- Signed and unsigned representation
- Register conventions
- ABI register names
- Memory representation
- Little-endian storage

### Why this mattered

Before implementing a CPU, I needed to understand exactly what the CPU is expected to execute. The register conventions, instruction formats and memory representation later became direct inputs to the CPU's decode and datapath logic.

**Detailed notes:** [`docs/theory/day-01-risc-v-fundamentals.md`](docs/theory/day-01-risc-v-fundamentals.md)

**Day folder:** [`day-01-risc-v-fundamentals/`](day-01-risc-v-fundamentals/)

---

## Day 2 — RISC-V ISA, Encoding and CPU Preparation

The second day moved from general RISC-V concepts toward the details required to implement instructions in hardware.

I studied how the 32-bit instruction is divided into fields and how different instruction formats place their operands and immediate values in different locations.

### Topics covered

- R-type instructions
- I-type instructions
- S-type instructions
- B-type instructions
- U-type instructions
- J-type instructions
- Opcode
- `funct3`
- `funct7`
- `rs1`
- `rs2`
- `rd`
- Immediate generation
- CPU datapath concepts

### The important transition

The key step was moving from:

> "What does this RISC-V instruction mean?"

to:

> "What hardware signals are required to make the processor execute this instruction?"

This directly prepared the work for instruction decoding and the CPU datapath in Days 4 and 5.

**Detailed notes:** [`docs/theory/day-02-isa-and-encoding.md`](docs/theory/day-02-isa-and-encoding.md)

**Day folder:** [`day-02-isa-and-encoding/`](day-02-isa-and-encoding/)

---

# Day 3 — Digital Logic, TL-Verilog and Makerchip

Day 3 was the transition from processor theory into hardware description and timing.

The work began with simple combinational logic and progressively introduced vectors, multiplexers, state, sequential calculations, pipelining and validity.

### 1. Makerchip

I worked in the Makerchip environment and used TL-Verilog to describe hardware behavior.

### 2. Combinational Logic

I worked with basic Boolean operations and simple combinational relationships.

```text
NOT
AND
OR
XOR
```

The objective was to become comfortable describing hardware behavior directly.

### 3. Vectors

The work then moved from individual bits to multi-bit signals.

This was important because the later RISC-V processor operates on 32-bit datapath values.

### 4. Multiplexer

The MUX introduced selection between alternative datapaths:

```text
              ┌─────────┐
input 1 ─────►│         │
              │   MUX   ├────► output
input 2 ─────►│         │
              └────┬────┘
                   │
                 select
```

This concept appears repeatedly later in the CPU, particularly in result selection and next-PC selection.

### 5. Calculator

I implemented calculator-style logic to practice arithmetic operations and control-based result selection.

### 6. Sequential Logic and State

The work then introduced state, showing how hardware can retain information across clock cycles.

### 7. Pipelined Logic

The calculator exercises were extended into pipelined forms. This introduced the idea that different parts of a computation can occupy different stages simultaneously.

### 8. Validity

Validity was introduced to distinguish meaningful transactions from empty/bubble pipeline stages.

### Why Day 3 mattered

These were not isolated exercises. They introduced the exact hardware concepts used later in the processor:

```text
MUX       → CPU control selection
Vector    → 32-bit datapath
State     → PC / registers
Pipeline  → CPU stages
Validity  → pipeline control
```

**Detailed theory:** [`docs/theory/day-03-tl-verilog.md`](docs/theory/day-03-tl-verilog.md)

**Lab record:** [`docs/labs/day-03-labs.md`](docs/labs/day-03-labs.md)

**TL-Verilog examples:** [`day-03-tl-verilog-makerchip/lab-snippets/`](day-03-tl-verilog-makerchip/lab-snippets/)

---

# Day 4 — Building the RISC-V CPU

Day 4 was the major transition from individual hardware exercises to an actual processor.

Instead of trying to build the complete CPU at once, the CPU was developed incrementally.

## CPU development sequence

```text
                    ┌─────────────┐
                    │  Next PC    │
                    └──────┬──────┘
                           ↓
                    ┌─────────────┐
                    │    Fetch    │
                    └──────┬──────┘
                           ↓
                    ┌─────────────┐
                    │   Decode    │
                    └──────┬──────┘
                           ↓
                    ┌─────────────┐
                    │ Register    │
                    │    File     │
                    └──────┬──────┘
                           ↓
                    ┌─────────────┐
                    │    ALU      │
                    └──────┬──────┘
                           ↓
                    ┌─────────────┐
                    │ Memory /    │
                    │ Writeback   │
                    └─────────────┘
```

## Step 1 — Next PC

The first CPU behavior was the program counter.

The normal sequence is:

```text
reset → PC = 0
normal → PC = PC + 4
```

The PC waveform was used as an early verification point.

## Step 2 — Instruction Fetch

Instruction memory was connected to the PC so that the processor could obtain the instruction corresponding to the current program address.

## Step 3 — Instruction Type Decode

The instruction was classified into the appropriate RISC-V format.

```text
R / I / S / B / U / J
```

## Step 4 — Immediate Decode

The CPU generated the appropriate 32-bit immediate according to the instruction format.

## Step 5 — Instruction Field Decode

The processor extracted fields such as:

```text
opcode
funct3
funct7
rs1
rs2
rd
```

and generated the appropriate validity/control information.

## Step 6 — ALU

The ALU became the execution unit for arithmetic, logical, comparison, shift and address-generation operations.

## Step 7 — Register File

The decoded source and destination registers were connected to the register-file interface.

The architectural zero register behavior was preserved.

## Step 8 — Branches

Branch target calculation and branch conditions were added.

The next-PC logic therefore evolved from:

```text
PC + 4
```

to:

```text
PC + 4
        OR
branch target
```

depending on control conditions.

## Step 9 — Testbench

The CPU was exercised using the workshop's test program.

The target calculation is:

```text
1 + 2 + 3 + 4 + 5 + 6 + 7 + 8 + 9 = 45
```

This provided an end-to-end functional check instead of testing individual signals only.

**Detailed theory:** [`docs/theory/day-04-risc-v-cpu.md`](docs/theory/day-04-risc-v-cpu.md)

**Lab record:** [`docs/labs/day-04-labs.md`](docs/labs/day-04-labs.md)

**Development notes:** [`day-04-risc-v-cpu/cpu-development-notes.md`](day-04-risc-v-cpu/cpu-development-notes.md)

---

# Day 5 — Pipelining and Completing the CPU

Day 5 focused on turning the CPU into a more complete pipelined design and dealing with the problems created by overlapping instructions.

## Pipeline

The CPU was organized into staged processing:

```text
P → D → R → E → W

P = Program counter / Fetch
D = Decode
R = Register Read
E = Execute
W = Writeback
```

This allows multiple instructions to occupy different stages simultaneously.

## Validity

A pipeline cannot assume that every cycle contains a meaningful instruction.

Validity therefore became part of the CPU control.

This is important after events such as:

- reset
- branch redirection
- pipeline bubbles
- replay

Invalid instructions must not accidentally write architectural state.

## Branch Handling

When a branch is taken, the sequential PC path must be replaced by the branch target.

Because the CPU is pipelined, this requires careful timing alignment between:

- branch instruction
- branch condition
- branch target
- validity
- next-PC selection

## Register-File Bypassing

Pipeline dependencies create situations where an instruction needs a value that was produced by an earlier instruction but has not yet become visible through the normal register-file path.

The solution developed was bypassing/forwarding.

```text
Previous instruction result
          │
          ▼
     ┌──────────┐
     │ Bypass   │
     │   MUX    │
     └────┬─────┘
          │
          ▼
     ALU operand
```

## Load / Store

The CPU was extended with memory operations.

For a store:

```text
ALU → memory address
register value → memory data
store enable → memory
```

For a load:

```text
ALU → memory address
memory → load data
load data → writeback
```

## Load Replay

Loads introduce another pipeline dependency because the loaded value becomes available later than a normal ALU result.

The CPU therefore includes replay handling so dependent execution proceeds using the correct loaded value.

## Final Integrated CPU

The final saved CPU source is:

[`day-05-pipelined-risc-v/final_cpu.tlv`](day-05-pipelined-risc-v/final_cpu.tlv)

Development variants are preserved here:

[`day-05-pipelined-risc-v/development-variants/`](day-05-pipelined-risc-v/development-variants/)

---

# Final Project — Pipelined RISC-V CPU

## Project Overview

The final outcome of the workshop was not simply a collection of independent exercises.

The exercises built toward an integrated processor.

### Final architecture

```text
                         ┌─────────────────┐
                         │   Next-PC MUX   │
                         └────────┬────────┘
                                  │
                                  ▼
                         ┌─────────────────┐
                         │       PC        │
                         └────────┬────────┘
                                  │
                                  ▼
                         ┌─────────────────┐
                         │ Instruction Mem │
                         └────────┬────────┘
                                  │
                                  ▼
                         ┌─────────────────┐
                         │     Decode      │
                         └───────┬─────────┘
                                 │
                    ┌────────────┴────────────┐
                    ▼                         ▼
             ┌─────────────┐          ┌─────────────┐
             │ Register    │          │ Immediate   │
             │    File     │          │ Generator   │
             └──────┬──────┘          └──────┬──────┘
                    │                         │
                    └────────────┬────────────┘
                                 ▼
                          ┌─────────────┐
                          │     ALU     │
                          └──────┬──────┘
                                 │
                       ┌─────────┴─────────┐
                       ▼                   ▼
                ┌────────────┐      ┌────────────┐
                │ Data Memory│      │ Writeback  │
                └─────┬──────┘      └─────┬──────┘
                      │                   │
                      └─────────┬─────────┘
                                ▼
                         Register File
```

## Main functionality

The integrated design covers:

- Program counter
- Instruction fetch
- RISC-V instruction decoding
- Immediate generation
- Register-file read/write
- ALU operations
- Branch comparison
- Branch target generation
- Next-PC selection
- Load/store memory interface
- Pipeline validity
- Branch handling
- Register-file bypassing
- Load replay
- Testbench verification

---

# What I Implemented

Across the five days, my work covered the following practical areas:

### RISC-V

- ISA fundamentals
- Instruction formats
- Instruction fields
- ABI/register conventions
- Immediate encoding
- Branches
- Loads and stores
- RISC-V CPU execution flow

### Digital Design

- Boolean logic
- Combinational circuits
- Vectors
- Multiplexers
- Sequential logic
- State
- Pipelining
- Validity

### TL-Verilog / Makerchip

- Hardware description
- Pipeline timing
- Stage-based design
- Signal validity
- CPU implementation

### CPU Microarchitecture

- PC
- Instruction memory
- Decode
- Register file
- ALU
- Branch control
- Data memory
- Writeback
- Pipeline stages
- Bypass logic
- Replay handling

### Verification

- Simulation
- Waveform inspection
- Intermediate checkpoints
- End-to-end testbench
- Final expected-result checking

---

# Verification

The main functional program computes:

```text
1 + 2 + 3 + 4 + 5 + 6 + 7 + 8 + 9
                         ↓
                        45
```

The final verification therefore checks whether the CPU produces the expected result.

Important intermediate verification points included:

| Checkpoint | Expected behavior |
|---|---|
| Reset PC | `0` |
| Sequential PC | `0, 4, 8, ...` |
| Instruction fetch | Instruction follows PC |
| Decode | Correct instruction type/fields |
| Immediate | Correct format-dependent value |
| ALU | Correct operation result |
| Branch | Correct target and taken decision |
| Validity | Invalid stages do not update state |
| Load/store | Correct memory interface |
| Bypass | Dependent instructions receive latest result |
| Final program | Result = `45` |

---

# Tools and Technologies

| Tool / Technology | Use |
|---|---|
| **RISC-V** | Processor ISA |
| **TL-Verilog** | Hardware description |
| **Makerchip** | Design, simulation and visualization |
| **RISC-V assembler environment** | Workshop test program |
| **Simulation / waveforms** | Functional verification |
| **Git / GitHub** | Versioned project portfolio |

---

# Repository Structure

```text
RISC-V-MYTH-Workshop-Portfolio/
│
├── README.md
│
├── day-01-risc-v-fundamentals/
│   └── README.md
│
├── day-02-isa-and-encoding/
│   └── README.md
│
├── day-03-tl-verilog-makerchip/
│   ├── README.md
│   └── lab-snippets/
│
├── day-04-risc-v-cpu/
│   ├── README.md
│   └── cpu-development-notes.md
│
├── day-05-pipelined-risc-v/
│   ├── README.md
│   ├── final_cpu.tlv
│   └── development-variants/
│
├── docs/
│   ├── theory/
│   ├── labs/
│   ├── images/
│   ├── reference/
│   └── PORTFOLIO_INDEX.md
│
└── project-showcase/
    ├── README.md
    ├── architecture.md
    ├── verification.md
    └── learning-outcomes.md
```

---

# Evidence

Screenshots from the work are preserved under [`docs/images/`](docs/images/).

These provide visual evidence of the development and Makerchip/simulation work rather than relying only on written descriptions.

---

# Skills Developed

By the end of the workshop, I developed practical exposure to:

- RISC-V ISA
- CPU architecture
- RTL/hardware description
- TL-Verilog
- Makerchip
- Digital logic
- Sequential circuits
- Pipeline design
- Instruction decoding
- ALU design
- Register-file integration
- Branch handling
- Load/store implementation
- Pipeline validity
- Data hazards
- Register-file bypassing
- Load replay
- Simulation and verification
- GitHub-based technical documentation

---

# Evidence and Reference Material

The repository includes:

- My course notes
- Lab/question material
- Supplied workshop slides
- Day-by-day theory
- Day-by-day lab documentation
- TL-Verilog examples
- CPU development files
- Final CPU source
- Development variants
- Screenshots/results

The reference material is stored under [`docs/reference/`](docs/reference/).

> **Copyright note:** The supplied workshop PDFs contain third-party course material. If this repository is made public, redistribution rights for those PDFs should be checked. They can alternatively be kept locally and excluded from the public GitHub repository.

---

# Acknowledgements

This portfolio is based on the supplied RISC-V MYTH Workshop course material and hands-on exercises.

The work is organized here as a personal learning and implementation record, with the final CPU presented as the culmination of the five-day progression.

---

## Final Takeaway

The most important outcome of the workshop was understanding the progression from a processor specification to hardware implementation:

```text
Instruction Set
      ↓
Instruction Encoding
      ↓
Hardware Logic
      ↓
Datapath
      ↓
Control
      ↓
Pipeline
      ↓
Hazard Handling
      ↓
Verification
      ↓
Working RISC-V CPU
```

The repository therefore documents not only **what I built**, but also **how the individual concepts and labs contributed to the final processor design**.
