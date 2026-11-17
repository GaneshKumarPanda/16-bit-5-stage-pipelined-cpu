# 16-bit 5-Stage Pipelined CPU — Verilog Implementation

A fully functional **16-bit pipelined processor** implemented in Verilog, featuring a classic 5-stage pipeline (IF → ID → EX → MEM → WB) with **data forwarding** and **branch hazard handling**.

---

## Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Pipeline Stages](#pipeline-stages)
- [Instruction Set Architecture (ISA)](#instruction-set-architecture-isa)
- [Instruction Formats](#instruction-formats)
- [Hazard Handling](#hazard-handling)
- [Module Descriptions](#module-descriptions)
- [File Structure](#file-structure)
- [Simulation & Usage](#simulation--usage)

---

## Overview

| Feature               | Details                          |
|-----------------------|----------------------------------|
| **Data Width**        | 16-bit                           |
| **Address Width**     | 8-bit (PC and memory addresses)  |
| **Register File**     | 8 × 16-bit general-purpose registers (R0–R7) |
| **Instruction Memory**| 256 × 16-bit words               |
| **Data Memory**       | 256 × 16-bit words               |
| **Pipeline Stages**   | 5 (IF, ID, EX, MEM, WB)          |
| **Forwarding**        | EX–EX and MEM–EX forwarding paths |
| **Branch Resolution** | Resolved in EX stage with flush  |
| **Implementation**    | Verilog HDL                      |

---

## Architecture

```
         ┌──────┐   ┌───────┐   ┌──────┐   ┌────────┐   ┌──────┐
  clk ──►│  IF  │──►│  ID   │──►│  EX  │──►│  MEM   │──►│  WB  │
reset ──►│      │   │       │   │      │   │        │   │      │
         └──┬───┘   └───┬───┘   └───┬──┘   └───┬────┘   └──┬───┘
            │  IF/ID    │  ID/EX    │  EX/MEM   │  MEM/WB   │
            │  Latch    │  Latch    │  Latch    │  Latch    │
            └───────────┴───────────┴───────────┴───────────┘
                               Forwarding paths ◄─────────────┘
```

The CPU is instantiated as the top-level `main` module which wires together all submodules and pipeline registers.

---

## Pipeline Stages

### Stage 1 — Instruction Fetch (IF)
- The **Program Counter (PC)** generates the address of the next instruction.
- **Instruction Memory** provides the 16-bit instruction word at the current PC.
- PC advances to `NPC = PC + 1` on each clock, or jumps to a branch target when a branch is taken.
- The PC holds its value when `halt` is asserted.

### Stage 2 — Instruction Decode (ID)
- The fetched instruction is decoded by the **Control Unit** using the 4-bit opcode (`IR[15:12]`).
- The **Register File** is read using the `rs` (`IR[11:9]`) and `rt` (`IR[8:6]`) fields.
- The **Immediate value** is sign-extended from the instruction based on instruction type:
  - R-type: 3-bit sign-extended from `IR[2:0]`
  - I-type: 6-bit sign-extended from `IR[5:0]`
  - J-type: 9-bit sign-extended from `IR[8:0]`
- All decoded values and control signals are latched into the **ID/EX pipeline register**.

### Stage 3 — Execute (EX)
- The **ALU** performs the operation specified by `ALUcontrol`.
- Operand selection:
  - `EX_A`: Driven by PC (for jumps) or register `rs`; subject to forwarding.
  - `EX_B`: Driven by register `rt`, immediate value, or constant `1`; subject to forwarding.
- **Data forwarding** resolves RAW hazards by selecting the most recent result from the EX/MEM or MEM/WB stage instead of the stale register file value.
- **Branch resolution**: A branch is taken when `ID_EX_branch` is asserted and register `rs == 0`.  
  `NPC = ID_EX_PC + ID_EX_imm[7:0]`
- ALU outputs flags: **Z** (Zero), **N** (Negative), **C** (Carry).

### Stage 4 — Memory Access (MEM)
- **Data Memory** is accessed for `load` and `store` instructions.
- Address is the lower 8 bits of the ALU output.
- Write on positive clock edge (when `mem_write = 1`), combinational read (when `mem_read = 1`).
- Results are latched into the **MEM/WB pipeline register**.

### Stage 5 — Write Back (WB)
- Writes results back to the **Register File**.
- Write data is selected between:
  - **Loaded Memory Data (LMD)** — for `load` instructions (`mem_to_reg = 1`)
  - **ALU result** — for all other register-writing instructions
- Destination register (`write_addr`) is determined by instruction type:
  - R-type: `IR[5:3]` (rd field)
  - I-type: `IR[8:6]` (rt field)
- Register R0 is **hardwired to zero** — writes to R0 are ignored.

---

## Instruction Set Architecture (ISA)

| Opcode | Mnemonic | Operation                              | Type   |
|--------|----------|----------------------------------------|--------|
| `0000` | `ADD`    | `rd = rs + rt`                         | R-type |
| `0001` | `ADDI`   | `rt = rs + imm6`                       | I-type |
| `0010` | `SUB`    | `rd = rs - rt`                         | R-type |
| `0100` | `NAND`   | `rd = ~(rs & rt)`                      | R-type |
| `0101` | `NOR`    | `rd = ~(rs | rt)`                      | R-type |
| `0110` | `LOAD`   | `rt = Mem[rs + imm6]`                  | I-type |
| `0111` | `STORE`  | `Mem[rs + imm6] = rt`                  | I-type |
| `1000` | `BEQ`    | `if (rs == 0) PC = PC + imm9`          | J-type |
| `1001` | `JUMP`   | `PC = PC + imm3` (via ALU with PC+1)   | R-type |
| `1010` | `SHL`    | `rt = rs << imm6`                      | I-type |
| `1011` | `SHR`    | `rt = rs >> imm6`                      | I-type |
| `1111` | `HALT`   | Stops the PC from advancing            | —      |

---

## Instruction Formats

### R-Type (opcode `0`, `2`, `4`, `5`)
```
 15      12 11    9  8     6  5     3  2     0
┌──────────┬────────┬────────┬────────┬────────┐
│  opcode  │   rs   │   rt   │   rd   │  imm3  │
│  [4 bit] │[3 bit] │[3 bit] │[3 bit] │[3 bit] │
└──────────┴────────┴────────┴────────┴────────┘
```

### I-Type (opcode `1`, `6`, `7`, `10`, `11`)
```
 15      12 11    9  8     6  5                0
┌──────────┬────────┬────────┬─────────────────┐
│  opcode  │   rs   │   rt   │      imm6       │
│  [4 bit] │[3 bit] │[3 bit] │    [6 bit]      │
└──────────┴────────┴────────┴─────────────────┘
```

### J-Type (opcode `8`)
```
 15      12 11    9  8                         0
┌──────────┬────────┬────────────────────────── ┐
│  opcode  │   rs   │          imm9             │
│  [4 bit] │[3 bit] │         [9 bit]           │
└──────────┴────────┴───────────────────────────┘
```

---

## Hazard Handling

### Data Hazards — Forwarding

The CPU implements **full forwarding** (bypass) to handle Read-After-Write (RAW) hazards without stalling:

- **EX → EX Forwarding**: If the instruction in EX/MEM is writing a register that the current EX stage reads, the ALU output from EX/MEM is forwarded to the EX stage input.
- **MEM → EX Forwarding**: If the instruction in MEM/WB is writing a register that the current EX stage reads, the write-back data is forwarded to the EX stage input.

Forwarding applies independently to both operands `A` and `B` (B forwarding is only active when the operand comes from a register, not an immediate).

> **Note**: Load-use hazards (a `LOAD` immediately followed by an instruction using the loaded value) are **not stalled** in the current implementation. Care should be taken in the program to insert a NOP or independent instruction between a LOAD and its first use.

### Control Hazards — Branch Flushing

- Branch resolution occurs in the **EX stage**.
- When a branch is taken (`branch_taken = ID_EX_branch && rs == 0`), both the **IF/ID** and **ID/EX** pipeline registers are **flushed** (cleared to NOP), discarding the two incorrectly fetched instructions.
- This results in a **2-cycle branch penalty** when a branch is taken.

---

## Module Descriptions

| File                  | Module            | Description                                                                 |
|-----------------------|-------------------|-----------------------------------------------------------------------------|
| `main.v`              | `main`            | Top-level module. Instantiates and connects all submodules.                |
| `pc.v`                | `pc`              | 8-bit Program Counter. Supports reset and halt.                            |
| `instruction_mem.v`   | `instruction_mem` | 256-word instruction ROM. Loads program from `program.mem` at simulation.  |
| `register_file.v`     | `register_file`   | 8 × 16-bit register file. R0 is hardwired to zero.                         |
| `control_unit.v`      | `control_unit`    | Combinational control signal decoder based on 4-bit opcode.                |
| `alu.v`               | `alu`             | 16-bit ALU. Supports ADD, SUB, NAND, NOR, SHL, SHR. Generates Z, N, C flags.|
| `data_memory.v`       | `data_memory`     | 256-word data memory. Synchronous write, combinational read.               |
| `IF_ID.v`             | `IF_ID`           | IF/ID pipeline register. Supports flush for branch handling.               |
| `ID_EX.v`             | `ID_EX`           | ID/EX pipeline register. Carries data, control, and ALU source signals.    |
| `EX_MEM.v`            | `EX_MEM`          | EX/MEM pipeline register. Carries ALU result, flags, and control signals.  |
| `MEM_WB.v`            | `MEM_WB`          | MEM/WB pipeline register. Carries LMD, ALU result, and write-back signals. |

---

## File Structure

```
pipelined-cpu-main/
├── main.v              # Top-level CPU module
├── pc.v                # Program Counter
├── instruction_mem.v   # Instruction Memory (loads program.mem)
├── register_file.v     # 8×16 Register File
├── control_unit.v      # Control Unit (opcode decoder)
├── alu.v               # Arithmetic Logic Unit
├── data_memory.v       # Data Memory
├── IF_ID.v             # IF/ID Pipeline Register
├── ID_EX.v             # ID/EX Pipeline Register
├── EX_MEM.v            # EX/MEM Pipeline Register
├── MEM_WB.v            # MEM/WB Pipeline Register
└── README.md           # This file
```

---

## Simulation & Usage

### Prerequisites
- A Verilog simulator such as **Xilinx Vivado**, **ModelSim**, or **Icarus Verilog (iverilog)**.

### Setting Up the Program

The instruction memory loads its contents from a hex file named `program.mem` at simulation start:

```verilog
$readmemh("program.mem", instruction_memory);
```

Create a `program.mem` file in the simulation working directory. Each line contains one 16-bit instruction in hexadecimal. Example:

```
// program.mem — adds R1 and R2, stores result in R3, then halts
0802    // ADDI R0, R1, 2    → R1 = 2
1083    // ADDI R0, R2, 3    → R2 = 3
0043    // ADD  R1, R2, R3   → R3 = R1 + R2 = 5
F000    // HALT
```

### Top-Level Ports

```verilog
module main(clk, reset);
    input clk;    // System clock
    input reset;  // Active-high synchronous reset
```

### Running a Simulation (Icarus Verilog)

```bash
iverilog -o cpu_sim main.v pc.v instruction_mem.v register_file.v \
         control_unit.v alu.v data_memory.v \
         IF_ID.v ID_EX.v EX_MEM.v MEM_WB.v

vvp cpu_sim
```

### Running in Vivado
1. Add all `.v` files as **Design Sources**.
2. Set `main` as the **top module**.
3. Create a testbench that drives `clk` and `reset`.
4. Place `program.mem` in the simulation working directory.
5. Run Behavioral Simulation.
