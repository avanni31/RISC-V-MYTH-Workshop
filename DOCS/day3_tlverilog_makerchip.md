# Day 3: Digital Logic with TL-Verilog in Makerchip IDE

**Agenda:** Logic gates → Makerchip platform → Combinational logic → Sequential logic → Pipelined logic → State/Hierarchy

Live updates, lab help, links: https://github.com/stevehoover/RISC-V_MYTH_Workshop

---

## 1. Logic Gates & Boolean Operators

Standard gate set covered: NOT, AND, OR, XOR, NAND, NOR, XNOR — with truth tables, Boolean arithmetic notation, Boolean calculus notation, and Verilog operators (`~`, `&`, `|`, `^`).

A full **combinational adder** (ripple-carry, built from chained full adders) was reviewed as the canonical combinational-circuit example: `S = A + B`.

---

## 2. Makerchip Platform

1. Go to [makerchip.com](https://makerchip.com) in a modern browser (not IDE) → click **IDE**.
2. Open **Tutorials → "Validity Tutorial"** → click **Load Pythagorean Example**.
3. Split panes and move tabs; zoom/pan the **Diagram** view with mouse wheel + drag; zoom the **Waveform** view with the "Zoom In" button.
4. Click `$bb_sq` in the code to highlight its path through the pipeline diagram.

### TL-Verilog identifiers & types
Symbol prefix + case/delimitation style determine the identifier's meaning:
- `$lower_case` → **pipe signal**
- `$CamelCase` → **state signal** ("Pascal case")
- `$UPPER_CASE` → **keyword signal**
- First token must start with two alpha characters; numbers end tokens (after alphas). `$base64_value` — good; `$bad_name_5` — bad.
- Numeric identifiers: `>>1` means "ahead by 1" (i.e., referencing the value 1 cycle prior).

---

## 3. Combinational Logic Labs

**A) Inverter**
- Open Examples → Load "Default Template."
- On line 16, replace `//...` with:
  ```tlv
  $out = ! $in1;
  ```
  *(No need to declare `$out`/`$in1`, and no need to assign `$in1` — random stimulus is auto-provided with a warning.)*
- Compile ("E" menu) & explore.

**B) Other logic** — build a 2-input gate using `&&`, `||`, `^`.

**Vectors** — `$out[4:0]` creates a 5-bit vector; arithmetic operators act on vectors as binary numbers:
```tlv
$out[4:0] = $in1[3:0] + $in2[3:0];
```

**Mux**
```tlv
$out = $sel ? $in1 : $in2;
```
Extended to vector form:
```tlv
$out[7:0] = $sel ? $in1[7:0] : $in2[7:0];
```
*Bit ranges can generally be assumed on the LHS, but with no assignment to a signal elsewhere they must be made explicit.*

**Chaining ternary operators** (priority mux), highest priority first:
```tlv
assign f = sel[0] ? a : sel[1] ? b : sel[2] ? c : d; // default d
```

**Lab: Combinational Calculator**
Implements `+ − × ÷` on two input values, selected by an encoded `$op[1:0]`:
```tlv
$val1[31:0] = $rand1[3:0];
$val2[31:0] = $rand2[3:0];
$sum[31:0]  = $val1 + $val2;
$diff[31:0] = $val1 - $val2;
$prod[31:0] = $val1 * $val2;
$quot[31:0] = $val1 / $val2;
$out[31:0]  = $op[1:0] == 2'd0 ? $sum :
              $op[1:0] == 2'd1 ? $diff :
              $op[1:0] == 2'd2 ? $prod : $quot;
```
Saved as a new project (bookmarked) — this calculator becomes the base for the sequential and pipelined labs below.

---

## 4. Sequential Logic

Sequential logic is **sequenced by a clock signal**. A D-flip-flop transitions "next state" to "state" on a rising clock edge; the circuit is constructed to enter a known state on reset. The whole circuit can be viewed as one big state machine: `Combo. Logic → next state → state → (feedback)`.

**Fibonacci series (reset)** — next value = sum of previous two (`1, 1, 2, 3, 5, 8, 13, ...`):
```tlv
$num[31:0] = $reset ? 1 : (>>1$num + >>2$num);
```

**Lab: Counter**
```tlv
$cnt[31:0] = $reset ? 0 : (>>1$cnt + 1);
```
Included in the saved calculator sandbox for later use (confirmed auto-save).

### Verilog value literals used
- `16'hF0` — 16-bit hex value
- `'0` — all 0s (width from context)
- `'X` — all don't-care bits
- `16'd5` — 16-bit decimal 5
- `5'b00XX1` — 5-bit value with don't-care bits
- `1` — 32-bit signed 1
- Simulator config: zero-extends/truncates mismatched widths (no warning); uses **2-state simulation** (no X's).

**Lab: Sequential Calculator**
Updated the calculator so `$val1` = result of the *previous* calculation each cycle, reset `$out` to zero, and saved the code outside Makerchip.

---

## 5. Pipelined Logic

**Motivating example — Pythagorean theorem in hardware:** `c = sqrt(a² + b²)`, distributed over 3 pipeline stages.

```tlv
|calc
   @1
      $aa_sq[31:0] = $aa * $aa;
      $bb_sq[31:0] = $bb * $bb;
   @2
      $cc_sq[31:0] = $aa_sq + $bb_sq;
   @3
      $cc[31:0] = sqrt($cc_sq);
```

This is roughly **3.5×** more compact than the equivalent SystemVerilog (which needs explicit `always_ff` staging registers per signal, per stage — very bug-prone to retime by hand).

### Retiming — easy & safe
Moving `$aa_sq` from stage `@1` → `@0`, and `$cc` from `@3` → `@4`, has **no functional impact** — staging is a purely physical attribute in TL-Verilog. This is one of TL-Verilog's biggest advantages over plain Verilog: retiming pipelines is trivial and safe, with far fewer chances of introducing bugs.

> **Key insight:** if the clock changes more often, we can present more data per unit time — i.e., pipelining more finely enables **higher frequency**. Values examined in one stage affect the output produced several stages later.

**Lab: Counter and Calculator in Pipeline** — put the calculator and counter into stage `@1` of a `|calc` pipeline; check log, diagram, waveform; confirm save.

**Lab: 2-Cycle Calculator** (for high frequency, calculate every other cycle):
1. Change alignment of `$out` to calculate every other cycle.
2. Change the counter to a single bit indicating "every other cycle."
3. Connect `$valid` to clear alternate outputs.
4. Retime the mux to `@2` (timing ease, no functional change).
5. Verify in waveform; save.

---

## 6. Validity

Validity is the notion of **when signals are meaningful**. Random/uninitialized data is invalid; well-defined ("white-box-like") data is valid. Validity is **not inherent to plain Verilog** — TL-Verilog adds it as a first-class concept.

```tlv
|calc
   @1
      $valid = ...;
   ?$valid
      @1
         $aa_sq[31:0] = $aa * $aa;
         $bb_sq[31:0] = $bb * $bb;
      @2
         $cc_sq[31:0] = $aa_sq + $bb_sq;
      @3
         $cc[31:0] = sqrt($cc_sq);
```

**Validity provides:**
- Easier debug
- Cleaner design
- Better error checking
- **Automated clock gating**

### Clock gating
- Clock signals distribute to *every* flip-flop; clocks toggle twice per cycle → this consumes significant power.
- Clock gating avoids unnecessary toggling.
- TL-Verilog can produce fine-grained gating/enables automatically from validity conditions — **most power in a circuit is used by the clock**, and gating avoids clocking when a signal is invalid.

**Lab: 2-Cycle Calculator with Validity**
```tlv
$valid_or_reset = $valid || $reset;
?$valid_or_reset
   @1
      $aa_sq[31:0] = $aa * $aa;
      ...
```
Used as a `when` condition for calculation instead of manually zeroing `$out`. Verified in waveform.

**Lab: Calculator with Single-Value Memory** — extended `$op` to 3 bits, added a memory MUX (`mem`/`recall`), selected the recall value in the output MUX, and verified behavior.

---

## 7. Hierarchy

TL-Verilog supports module-like hierarchy (`|pipeline_name`, `/instance_array[...]`) to replicate logic — e.g. a Conway's Game-of-Life style grid using `/xx[X_SIZE-1:0]` / `/yy[Y_SIZE-1:0]` instance arrays, with "lexical re-entrance" letting you re-open a pipeline (`|default`) from another hierarchical context to add more logic to it.

This hierarchy mechanism is also how a 1-read/1-write **array** (register-file-style memory) is implemented at a low level using per-entry write-enable comparison logic (`#entry == wr_index`) and `$RETAIN` semantics.

**Lab: Hierarchy** — completed the "Hierarchy" tutorial in a new Makerchip window, reproducing the Pythagorean example with `/coord[0]` / `/coord[1]` behavioral hierarchy in place of separate `$aa`/`$bb` signals.

**Lab: Calculator with Memory** — replaced the single-entry `$mem[31:0]` with an 8-entry memory array; `mem`/`recall` map to `wr_en`/`rd_en`; `$val1[2:0]` provides the read/write index. Verified in simulation.

---

**→ Day 4:** these building blocks (mux, ALU-like combinational logic, sequential counters, pipelined validity) are exactly what's needed to build a **Basic RISC-V CPU**.
