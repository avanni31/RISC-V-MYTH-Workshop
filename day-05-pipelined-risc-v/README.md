# Day 5 — Pipelining and Completing the RISC-V CPU

This directory contains the final saved TL-Verilog CPU source recovered from the supplied workshop work, plus the development variants saved during the load/store/jump stages.

## Final source

[`final_cpu.tlv`](final_cpu.tlv)

The final source contains the integrated sum-1-to-9 test program and the CPU implementation.

## Major features present in the final source

### PC control

The PC handles:

- reset
- sequential increment
- valid taken branch redirection
- valid load replay

### Instruction processing

- instruction memory
- instruction validity
- instruction type decode
- immediate generation
- field extraction
- instruction-specific decode

### Execution

The ALU logic covers:

- ADD / ADDI
- AND / ANDI
- OR / ORI
- XOR / XORI
- shifts
- SUB
- SLT / SLTI
- SLTU / SLTIU
- LUI
- AUIPC
- JAL / JALR
- load/store address generation

### Control hazards

Branch target and taken-branch signals are aligned through the pipeline. PC redirection is qualified with validity.

### Data hazards

The source contains register-file read bypassing so recent results can be used by dependent instructions before they are naturally visible through the register file.

### Memory

The source includes:

- store enable
- store data
- data-memory address
- load enable
- load-data return
- load-result writeback

### Verification

The source contains a pass condition for the expected sum:

```text
45
```

## Development variants

The `development-variants/` folder preserves the saved variants associated with the load/store/jump work.

These are intentionally kept as separate files so the repository shows progression rather than only presenting the final implementation.
