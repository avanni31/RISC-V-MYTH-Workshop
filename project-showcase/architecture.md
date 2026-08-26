# CPU Architecture

## High-level architecture

```text
                       ┌──────────────────┐
                       │   Next-PC Logic  │
                       └────────┬─────────┘
                                │
                                ▼
                         ┌────────────┐
                         │     PC     │
                         └─────┬──────┘
                               │
                               ▼
                    ┌────────────────────┐
                    │ Instruction Memory │
                    └─────────┬──────────┘
                              │
                              ▼
                    ┌────────────────────┐
                    │      Decode        │
                    └───────┬────────────┘
                            │
                  ┌─────────┴─────────┐
                  ▼                   ▼
             ┌─────────┐       ┌────────────┐
             │   RF    │       │ Immediate  │
             │  Read   │       │ Generator  │
             └────┬────┘       └──────┬─────┘
                  │                   │
                  └─────────┬─────────┘
                            ▼
                         ┌───────┐
                         │  ALU  │
                         └───┬───┘
                             │
                    ┌────────┴────────┐
                    ▼                 ▼
               ┌────────┐        ┌──────────┐
               │ D-MEM  │        │Writeback │
               └────┬───┘        └────┬─────┘
                    │                 │
                    └────────┬────────┘
                             ▼
                       ┌───────────┐
                       │ RF Write  │
                       └───────────┘
```

## Pipeline

The final CPU is organized around staged timing. The workshop presents the pipeline as a waterfall of instructions moving through:

```text
P → D → R → E → W
```

The exact signal alignment is visible in `day-05-pipelined-risc-v/final_cpu.tlv`.
