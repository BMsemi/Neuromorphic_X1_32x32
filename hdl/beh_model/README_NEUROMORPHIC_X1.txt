# NEUROMORPHIC_X1 ReRAM Simulation

This project simulates a behavioral ReRAM memory integrated into a Wishbone-compatible interface and connected to a top-level wrapper called `NEUROMORPHIC_X1`. It is intended strictly for simulation (non-synthesizable) and demonstrates a functional neuromorphic compute-in-memory macro.

---

## 📁 File Overview

| File Name                      | Description |
|-------------------------------|-------------|
| `NEUROMORPHIC_X1_macro.sv`    | Macro-level behavioral definition of the neuromorphic ReRAM macro. Exposes analog and digital pins with internal logic. |
| `NEUROMORPHIC_X1.sv`          | Top-level wrapper that hardwires all pins to the macro instance. |
| `ReRAM_Wishbone_Interface.sv` | Integration layer that connects the ReRAM logic to the Wishbone interface. Manages address decoding, read/write control. |
| `wishbone_slave_interface.sv` | Implements standard Wishbone slave protocol and handshaking logic. Detects valid Wishbone transactions. |
| `tb_ReRAM_Wishbone_Interface.sv` | Testbench that simulates write and read transactions on the ReRAM via Wishbone interface. |
| `run.do`                      | Simulation script for QuestaSim/ModelSim. Compiles all files and starts waveform view. |

---

## ⚙️ Functionality Overview

### 🧠 ReRAM Behavior (Inside `NEUROMORPHIC_X1_macro`):
- **Write Operation**:
  - Data, address, and select provided through Wishbone interface
  - Write takes effect after `EN` is LOW for 10 clock cycles
- **Read Operation**:
  - Adds a fixed latency of **44 clock cycles**
  - Output data is **held for 1 clock cycles**
  - Read data is available on `DO[31:0]`
	- Note: Until all the datas are written to the Crossbar Array the user should not initiate any transaction

### 🔗 Wishbone Interface:
- Expects address `0x3000_000C` with `SEL = 4'b0010`
- Handles both read and write transactions using `EN`, `R_WB`, `SEL`, `AD`, and `DI`
- Asserts `func_ack` upon valid transaction completion

---

## 🧪 Simulation Instructions

### Requirements:
- QuestaSim / ModelSim with SystemVerilog support

### Steps to Simulate:

1. Launch QuestaSim/ModelSim
2. In transcript type `cd {" File's Location "}`
3. Type `do run.do`
4. Run's the `run.do` script from the simulation terminal:


This will:
- Compile all necessary `.sv` files
- Launch the testbench
- Add signals to the waveform
- Run the simulation for a preset duration

---

## 🧪 Testbench Features

The testbench `tb_ReRAM_Wishbone_Interface.sv` performs:

1. **Write 32 entries**, then read back 20  
2. **Write 10 more**, read back 22 (overlapping)  
3. **Write 25**, then read 15  
4. **Apply reset mid-op** and verify correct recovery  
5. **Final 7 writes & reads** to validate reset and data correctness  

Assertions and logging statements validate correctness of data read-back and handshaking.

---

## 📈 Output

- Console prints of each Wishbone write and read transaction  
- Waveform displays:
  - Wishbone interface signals
  - ReRAM behavior (EN, func_ack, DO, etc.)
  - Internal ReRAM timing delays
  - Top-level analog and scan pins (as stubs)

---

## ⚠️ Notes

- The ReRAM memory and timing behavior are purely **behavioral models**  
- Not meant for synthesis or layout  
- This platform is designed to test **timing behavior** (read/write delays, data hold) and **Wishbone protocol logic** in a neuromorphic memory macro context  
