
# ReRAM Wishbone Interface Simulation

This project models and simulates a behavioral ReRAM memory array connected to a Wishbone-compatible slave interface. It is designed for simulation purposes only and is not intended to be synthesizable.

---

## 📁 File Overview

| File Name                       | Description |
|--------------------------------|-------------|
| `wishbone_slave_interface.sv`  | Implements Wishbone protocol decoding and handshaking logic. Detects valid read/write transactions to a fixed memory address and communicates with the ReRAM functional block. |
| `ReRAM_functional.sv`          | Behavioral model of a 32x32 ReRAM memory. Includes internal memory array, write, and delayed read logic. |
| `ReRAM_Wishbone_Interface.sv`  | Top-level integration wrapper that connects the Wishbone protocol interface and ReRAM functional logic. |
| `tb_ReRAM_Wishbone_Interface.sv` | SystemVerilog testbench to validate correct operation. Simulates random writes and reads with assertion of Wishbone signals. |
| `run.do`                       | QuestaSim (ModelSim) simulation script to compile and run the simulation and add waveforms. |

---

## 🧠 Functionality Summary

- **Wishbone Interface**
  - Matches address `0x3000_000c`
  - Only accepts when `wbs_sel_i == 4'b0010`
  - Read or write controlled by `wbs_we_i`

- **ReRAM Functional Block**
  - 32x32 memory array (behavioral only)
  - Write: Takes row, col, and data from `wbs_dat_i`
  - Write: Adds fixed latency of 10 cycles for 1 data to be written to the Crossbar Array after 'EN' Signal goes LOW
  - Read: Adds fixed latency of 44 cycles and holds read data for 1 cycles
  - Acknowledges completion via `func_ack`
  - Note: Until all the datas are written to the Crossbar Array the user should not initiate any transaction
	
---

## 🧪 Simulation Instructions

### Prerequisites:
- QuestaSim / ModelSim with SystemVerilog support

### Steps:

1. Launch QuestaSim/ModelSim
2. In transcript type `cd {" File's Location "}`
3. Type `do run.do`
2. Run's the `run.do` script from the simulation terminal:


This will:
- Compile all `.sv` files
- Launch the testbench `tb_ReRAM_Wishbone_Interface`
- Add all necessary signals to the waveform window
- Run the simulation

---

## 🧪 Testbench Behavior

The testbench executes a variety of sequences:

1. Write 32 entries and read back 20
2. Write 10 entries and read back 22 (includes leftover data)
3. Write 25 entries and read 15
4. Apply reset mid-operation and verify behavior
5. Write and read 7 entries to check reset recovery

Randomized data and addresses are used to validate different write/read paths and timing behavior.

---

## 📬 Output

- Console logs will show each write and read operation with timestamps
- Waveform will display:
  - Top-level interface signals
  - Wishbone transaction handshaking
  - ReRAM functional logic

---

## ⚠️ Notes

- This design is purely behavioral and not synthesizable
- Delay and hold time values are for simulation/testing only
- Functional block uses simple queueing/delay logic (not physical timing models)

---
