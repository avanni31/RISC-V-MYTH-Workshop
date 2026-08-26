# Day 4 — Coding the RISC-V CPU

Day 4 is the first processor-building phase.

## Implementation sequence

```text
Next PC
  ↓
Fetch
  ↓
Instruction Type Decode
  ↓
Immediate Decode
  ↓
Instruction Field Decode
  ↓
ALU
  ↓
Register File Write
  ↓
Branches
  ↓
Testbench
```

## Main verification target

The supplied workshop program computes:

```text
1 + 2 + ... + 9 = 45
```

The testbench monitors the appropriate register and reports pass/fail.

## Detailed notes

See:

- [`../../docs/theory/day-04-risc-v-cpu.md`](../../docs/theory/day-04-risc-v-cpu.md)
- [`../../docs/labs/day-04-labs.md`](../../docs/labs/day-04-labs.md)
- [`cpu-development-notes.md`](cpu-development-notes.md)
