# CPU Development Notes

## Next PC

The first implementation establishes:

```text
reset → 0
otherwise → PC + 4
```

## Fetch

Instruction memory is connected to the PC-derived instruction address.

## Decode

The instruction is classified into R/I/S/B/U/J types. The decoder then exposes only the fields valid for the relevant instruction classes.

## ALU

The ALU result becomes the central execution result used by arithmetic instructions, address generation and other instruction classes.

## Register File

The writeback path connects the decoded `rd` field to the result.

`x0` must remain zero.

## Branches

The branch unit computes a target and a taken/not-taken decision. The next-PC mux chooses between sequential execution and the branch target.

## Testbench

The sum-1-to-9 program provides an end-to-end functional check.
