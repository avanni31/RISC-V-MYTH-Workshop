# Verification

## Functional test

The CPU uses the workshop's sum-1-to-9 program.

Expected:

```text
45
```

## Verification checkpoints

### PC

After reset:

```text
0 → 4 → 8 → 12 → ...
```

### Fetch

The instruction at the PC is visible through the instruction-memory interface.

### Decode

Instruction class and fields are checked in simulation.

### ALU

Instruction-specific result paths are checked.

### Branch

The taken-branch condition and target must align with the pipeline stage where the branch resolves.

### Validity

Invalid pipeline instructions must not:

- write the register file
- redirect the PC

### Load

Load data must return to the correct destination register.

### Bypass

A dependent instruction must receive the most recent value when a previous pipeline stage has already produced it.

### Final pass condition

The final integrated test checks the expected sum result.
