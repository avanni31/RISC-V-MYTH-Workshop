# Day 5: Pipelining and Completing the CPU

## Waterfall logic diagram

The single-cycle core from Day 4 is conceptually "unrolled" across cycles — each instruction's PC → Dec → RF Rd → ALU → RF Wr path is offset by one cycle from the next, using `>>1` to reference the previous cycle's values:

```
 stage 0        stage 1                  stage 2
┌────┐   ┌───┐  ┌─────┐  ┌───────┐  ┌───┐  ┌───────┐
│ PC │──►│+1 │─►│ Dec │─►│ RF Rd │─►│ALU│─►│ RF Wr │
└────┘   └───┘  └─────┘  └───────┘  └───┘  └───────┘
  IMem Rd
   ▲                                                 │
   │                     >>1 (next instruction) ─────┘
```

---

## Lab: 3-Cycle `$valid`

1. Create `$start` to provide the first `$valid` pulse (reset the *previous* cycle, but not the current one).
2. Create `$valid`: `0` during `$reset`, `1` for `$start`, `>>3$valid` otherwise. Checked in simulation.

## Lab: 3-Cycle RISC-V

1. Avoid writing the register file for **invalid** instructions.
2. Avoid redirecting PC for invalid (branch) instructions — introduced:
   ```tlv
   $valid_taken_br = $valid && $taken_br;
   ```
   and used it in the PC mux.
3. Updated inter-instruction dependency alignments to `>>3` (to match the new pipeline depth).
4. Debugged until passing; confirmed save.
5. Partitioned logic into the pipeline stages shown above; added stages and cut-n-pasted code. For the register file, used `m4+rf(@2, @3)`, implying `>>2` (since the previous 2 instructions don't update the RF, `>>1`, `>>2`, `>>3` are functionally equivalent here).

## Lab: Register File Bypass

Read-after-write hazard: RF reads must reflect data written **2 instructions ago**, not 3.

1. RF read uses the RF as written 2 instructions ago (instead of 3).
2. Updated `$srcX_value` expressions to select the *previous* `$result` if it was written to the RF (write enable was set) and if the previous `$rd == $rsX`.
3. *(Should have no visible effect on the final output yet — this is a correctness fix for pipelining, not a behavior change.)*

## Lab: Branches (3-cycle re-alignment)

1. Replaced the `@1 $valid` assignment with an `@3 $valid` assignment, based on the non-existence of a valid `$taken_br` in the previous two instructions (to correctly invalidate instructions "in the shadow" of a taken branch).
2. Incremented PC every cycle (not every 3 cycles).
3. PC redirect for branches was already 3-cycle — no change needed there.
4. Debugged; saved outside Makerchip.

## Lab: Complete Instruction Decode

Completed decode for all remaining RV32I instructions (except loads):
```tlv
$dec_bits[10:0] = {$funct7[5], $funct3, $opcode};
$is_beq = $dec_bits ==? 11'bx_000_1100011;
// ... full opcode/funct3/funct7 table completed for
// SUB, SLL, SLT, SLTU, XOR, SRL, SRA, OR, AND,
// SLTI, SLTIU, XORI, ORI, ANDI, SLLI, SRLI, SRAI, LUI, AUIPC, JAL, JALR

`BOGUS_USE($is_beq $is_bne ...)
```
All loads (`LB`/`LH`/`LW`/`LBU`/`LHU`) are treated the same — generated a single `$is_load` flag based on opcode only. Confirmed save.

## Lab: Complete ALU

Assigned `$result` for all remaining instructions:

| Instr | Expression |
|---|---|
| ADD | `$src1_value + $src2_value` |
| SUB | `$src1_value - $src2_value` |
| SLL | `$src1_value << $src2_value[4:0]` |
| SRL | `$src1_value >> $src2_value[4:0]` |
| SLTU | `$src1_value < $src2_value` |
| SLTIU | `$src1_value < $imm` |
| ANDI | `$src1_value & $imm` |
| ORI | `$src1_value \| $imm` |
| XORI | `$src1_value ^ $imm` |
| ADDI | `$src1_value + $imm` |
| SLLI | `$src1_value << $imm[5:0]` |
| SRLI | `$src1_value >> $imm[5:0]` |
| AND | `$src1_value & $src2_value` |
| OR | `$src1_value \| $src2_value` |
| XOR | `$src1_value ^ $src2_value` |
| LUI | `{$imm[31:12], 12'b0}` |
| AUIPC | `$pc + $imm` |
| JAL | `$pc + 4` |
| JALR | `$pc + 4` |
| SRAI | `{ {32{$src1_value[31]}}, $src1_value} >> $imm[4:0]` |
| SRA | `{ {32{$src1_value[31]}}, $src1_value} >> $src2_value[4:0]` |
| SLT | `($src1_value[31] == $src2_value[31]) ? $sltu_rslt : {31'b0, $src1_value[31]}` |
| SLTI | `($src1_value[31] == $imm[31]) ? $sltiu_rslt : {31'b0, $src1_value[31]}` |

*(SLT/SLTI need intermediate result signals — `$sltu_rslt`/`$sltiu_rslt` — computed from the corresponding unsigned comparisons.)*

## Lab: Redirect Loads

1. Clear `$valid` in the "shadow" of a load (same pattern as for branches).
2. Select PC from 3 instructions ago for load redirection.
3. Debugged; confirmed save.

## Lab: Load Data

1. For loads/stores (`$is_load`/`$is_s_instr`), computed the same address-result as for `addi` (base + offset).
2. Added the RF-write-data MUX to select `$ld_data` for `! $valid` instructions.
3. Enabled write of `$ld_data` **2 instructions after** a valid `$load`.
4. Confirmed save.
5. Uncommented `//m4+dmem(@4)` — a mini 1-read/1-write memory (16 entries × 32 bits wide):
   ```
   $reset, $dmem_wr_en, $dmem_addr[3:0], $dmem_wr_data[31:0],
   $dmem_rd_en, $dmem_rd_index[5:0]  → $dmem_rd_data
   ```
6. Connected interface signals using address bits `[5:2]` to perform load and store (when valid).

## Lab: Load/Store in Program

Modified the test program to store the final result value to address 4, then load it back into `x15`:
```
m4_asm(SW, r0, r10, 100)
m4_asm(LW, r15, r0, 100)
```
Updated the passing condition to check `xreg[15]`. Debugged whether the loop properly falls through and executes the store/load.

## Lab: Jumps

1. Defined `$is_jump` (JAL or JALR), and — like `$taken_br` — created invalid cycles in its shadow.
2. Computed `$jalr_tgt_pc` (`SRC1 + IMM`).
3. Selected the correct `$pc` for JAL (`>>3$br_tgt_pc`) and JALR (`$jalr_tgt_pc`).
4. Saved.

---

## Result

At this point, the core is a **complete, pipelined RV32I subset processor** — able to fetch, decode, execute, branch/jump, load, and store — verified end-to-end by summing `1..9` into register `x10` (and, after the load/store lab, round-tripping that result through data memory into `x15`).

**→ Next steps (beyond the workshop's scope in these notes):** run the same TL-Verilog RISC-V CPU on an actual RISC-V hardware target (see `RV32.v` core in `riscv_workshop_collaterals`), simulated with a testbench in Verilog, to see the same C program execute on a CPU implemented in real digital logic rather than in Makerchip's abstract simulation.
