# Day 5 — Pipelining and Completing the CPU

Day 5 extends the CPU into a pipelined implementation.

## Pipeline

The workshop uses a staged CPU structure corresponding to:

```text
P → D → R → E → W
```

where the stages represent program counter/fetch, decode, register read, execute, and writeback.

## Why pipeline?

Pipelining allows multiple instructions to occupy different stages at the same time. This improves throughput compared with completing one entire instruction before beginning the next.

## Validity

A `valid` signal identifies whether the instruction occupying a pipeline stage represents a real transaction.

This is especially important after:

- reset
- branch redirection
- pipeline bubbles

The workshop specifically adds validity handling so invalid instructions do not incorrectly write the register file or redirect the PC.

## Branch hazards

A taken branch is resolved after the branch has entered the pipeline. Therefore, the PC redirect and associated signals must be aligned with the stage at which the branch result becomes available.

## Load replay

A load obtains its data later than a normal ALU instruction. The integrated design therefore uses a load-related replay mechanism so dependent instructions can obtain the loaded value correctly.

## Register-file bypassing

The final development adds forwarding paths from later pipeline stages back to register-file read values.

Conceptually:

```text
recent writeback
      ↓
   bypass mux
      ↓
register-file operand
      ↓
     ALU
```

This reduces incorrect reads caused by instructions that depend on results that have not yet reached the architectural register file.

## Final verification

The completed design uses a pass condition based on the expected result of the workshop's sum-1-to-9 program.

## Key takeaway

Day 5 is where the individual CPU blocks become a functioning pipelined microarchitecture with control, timing, hazards and data dependencies handled explicitly.
