# Day 4: Coding a Basic RISC-V CPU Subset

## Concept overview

- **Program Counter (PC)** points into instruction memory.
- PC value goes into **Instruction Memory** (`IMem Rd`), and the result is interpreted through **decode logic**.
- A branch instruction goes directly to its targeted instruction; the incremented PC is otherwise computed by an adder for the fall-through case.
- Decoded, ALU-ready instructions go into the **Register File Read (RF Rd)** stage, then values are operated on by the **ALU** (the "calculator" built on Day 3), and the result is written back to the register file (**RF Wr**).
- **Memory (DMem Rd/Wr)** handles load data for load/store instructions.

```
        ┌────┐      ┌─────┐      ┌───────┐      ┌─────┐      ┌───────┐
 PC ───►│ PC │─────►│ Dec │─────►│ RF Rd │─────►│ ALU │─────►│ RF Wr │
        └────┘      └─────┘      └───────┘      └─────┘      └───────┘
           ▲            │
           │            ▼
        IMem Rd    (branch target)
```

---

## Lab: Next PC

Reset `$pc[31:0]` to 0 if the *previous* instruction was a "reset instruction" (`>>1$reset`), and increment by 1 instruction (`32'd4` bytes) thereafter — branch support added later.

Check PC value in simulation and confirm save: **PCs after reset should read 0, 4, 8, ...**

## Lab: Fetch (part 1 & 2)

1. Add the instruction memory containing the program (provided). Uncomment `//m4+imem(@1)` and `//m4+cpu_viz(@4)`, compile, observe log errors.
2. `imem` interface:
   - In: `$imem_rd_en` (read enable)
   - In: `$imem_rd_addr[M4_IMEM_INDEX_CNT-1:0]`
   - Out: `$imem_rd_data[31:0]`
3. Connect the `imem` interface to read into `$instr[31:0]`, addressed by `$pc[M4_IMEM_INDEX_CNT+1:2]`, enabled every cycle after reset. Check `$instr` in simulation and confirm save.

## Lab: Instruction Types Decode

`instr[6:2]` determines instruction type: **I, R, S, B, J, U** (per the RV32I opcode map table). E.g.:
```tlv
$is_i_instr = $instr[6:2] ==? 5'b0000x ||
              $instr[6:2] ==? 5'b001x0 ||
              ...;
```
Check behavior in simulation.

## Lab: Instruction Immediate Decode

Form `$imm[31:0]` based on instruction type, per the immediate-field layout for I/S/B/U/J formats:
```tlv
$imm[31:0] = $is_i_instr ? { {21{$instr[31]}}, $instr[30:20] } :
             $is_s_instr ? { {21{$instr[31]}}, $instr[30:25], $instr[11:7] } :
             $is_b_instr ? { {20{$instr[31]}}, $instr[7], $instr[30:25], $instr[11:8], 1'b0 } :
             $is_u_instr ? { $instr[31:12], 12'b0 } :
             $is_j_instr ? { {12{$instr[31]}}, $instr[19:12], $instr[20], $instr[30:21], 1'b0 } :
             32'b0;
```
Check behavior in simulation.

## Lab: RISC-V Instruction Field Decode

Using `when` conditions to gate field extraction to the relevant instruction types:
```tlv
$rs2_valid = $is_r_instr || $is_s_instr || $is_b_instr;
?$rs2_valid
   $rs2[4:0] = $instr[24:20];
```
Same pattern applied to `rs1`, `rd`, `funct3`, `funct7` decode. Check behavior in simulation.

## Lab: Instruction Decode (opcode/funct3/funct7 → instruction identity)

RV32I base instruction set (except FENCE/ECALL/EBREAK) decoded via `$dec_bits`:
```tlv
$dec_bits[10:0] = {$funct7[5], $funct3, $opcode};
$is_beq = $dec_bits ==? 11'bx_000_1100011;
// ... $is_bne, $is_blt, $is_bge, $is_bltu, $is_bgeu
// ... $is_add, $is_sub, $is_addi, etc.

// Until instructions are implemented, quiet warnings:
`BOGUS_USE($is_beq $is_bne ...)
```
Completed the circled instructions (BEQ, BNE, BLT, BGE, BLTU, BGEU, ADD, ADDI) — check behavior in simulation and confirm save.

## Lab: ALU

Assigned the ALU `$result` for `ADD` and `ADDI` (others filled in on Day 5):
```tlv
$result[31:0] = $is_addi ? $src1_value + $imm :
                 ...
                 32'bx;
```

## Lab: Register File Write

2-read, 1-write register file interface:
```
$reset, $rf_wr_en, $rf_wr_index[4:0], $rf_wr_data[31:0]
$rf_rd_en1, $rf_rd_index1[4:0]  → $rf_rd_data1
$rf_rd_en2, $rf_rd_index2[4:0]  → $rf_rd_data2
```
1. Provide proper input assignments to enable RF write (`wr`) of `$result` to `$rd` (destination register) when `$rd_valid` for a valid instruction.
2. Debug in simulation — should be writing and reading registers.
3. **RISC-V rule:** `x0` is "always-zero" — writes to it must be ignored. Added logic to disable write when `$rd == 0`.
4. Saved outside of Makerchip.

## Lab: Branches

Branch condition table:
| Branch | Condition |
|---|---|
| BEQ | `x1 == x2` |
| BNE | `x1 != x2` |
| BLT | `(x1 < x2) ^ (x1[31] != x2[31])` |
| BGE | `(x1 >= x2) ^ (x1[31] != x2[31])` |
| BLTU | `x1 < x2` |
| BGEU | `x1 >= x2` |

1. Determined `$taken_br` as a ternary expression based on `$is_bxx`, defaulting to `1'b0`.
2. Computed `$br_tgt_pc` (PC + immediate).
3. Modified the `$pc` MUX expression to use the *previous* `$br_tgt_pc` when the previous instruction was `$taken_br`.
4. Checked behavior in simulation — **the program now correctly sums values `{1..9}`!** Debugged as needed and saved outside Makerchip.

## Lab: Testbench

Tell Makerchip when the simulation passes by monitoring register `x10` (containing the sum), within stage `@1`:
```tlv
*passed = |cpu/xreg[10]>>5$value == (1+2+3+4+5+6+7+8+9);
```
Checked the log for the "passed" message.

---

**→ Day 5:** Complete Pipelined CPU — turning this single-cycle core into a properly pipelined design with hazard handling.
