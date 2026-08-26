# Day 3 — Digital Logic with TL-Verilog and Makerchip

The workshop slides define Day 3 around:

- Logic gates
- Makerchip
- Combinational logic
- Sequential logic
- Pipelined logic
- State

## Logic gates

The core Boolean operations covered are:

- NOT
- AND
- OR
- XOR
- NAND
- NOR
- XNOR

## Combinational logic

A combinational circuit's output is determined by its current inputs.

The first lab uses a simple inverter:

```tl-verilog
$out = !$in1;
```

The workshop then extends this into other Boolean operations.

## Vectors

TL-Verilog supports vector signals such as:

```tl-verilog
$out[4:0]
```

Arithmetic can operate on vectors as binary values.

## Multiplexer

The basic MUX expression is:

```tl-verilog
$out = $sel ? $in1 : $in2;
```

The lab extends the same idea to vector-width inputs.

## Sequential logic

Sequential logic introduces state that changes with clock cycles.

The workshop uses a running calculator and counter examples to introduce stateful behavior.

## Pipelined logic

TL-Verilog's timing abstractions make pipeline staging explicit. The workshop demonstrates how a calculation can be separated across stages so different inputs can be processed concurrently.

## Validity

Validity is introduced as a way to distinguish meaningful pipeline transactions from bubbles or reset-related cycles.

## Hierarchy

The notes also introduce hierarchy as a way of encapsulating and reusing hardware logic.

## Key takeaway

Day 3 is the bridge from individual logic expressions to the timing and structural concepts needed to build a CPU.
