# 🌀 Washing Machine Controller

This repository contains the **Verilog** implementation and verification of a **Washing Machine Controller** finite state machine (FSM).

---

## 🔍 Project Overview

The controller simulates a real-world washing machine by managing:

* Power on/off and Idle state
* Mode selection (QuickWash, Sports, GentleCare, Denim, Wool, Synthetics)
* Manual timer configuration (≥ 120 s)
* Cycle stages: **Wash → Rinse → Drain → Dry → Completion**
* Error handling: door open, insufficient water
* Pause/Resume functionality
* Automatic power-off on completion or timeout

All behavior is driven by a **Mealy/Moore FSM** with robust input validation and error resilience.

---

## 📁 Repository Structure

All project files are contained in the **Washing\_Machine** folder:

```
Washing_Machine/
├── Design_Code.v          # Verilog implementation of the FSM and supporting modules
├── Testbench_code.v       # Testbench for functional verification
├── simulation.do          # ModelSim simulation script and waveform commands
├── Coverage.txt           # Text report of coverage metrics (assertions, FSM, statements, toggles)
```

The PDF report (`Washing_Machine_Report.pdf`) is located outside this folder.

---

## ⚙️ Design Specifications

| Input Signal        | Description                             |
| ------------------- | --------------------------------------- |
| `clk`               | System clock                            |
| `powerButton`       | Toggle machine on/off or pause          |
| `configu`           | Enter manual timer configuration mode   |
| `run`               | Start cycle after mode/config selection |
| `mode[2:0]`         | Preset modes (000–101)                  |
| `manualTimer[31:0]` | Custom timer (min 120 s)                |
| `door_error`        | Door-open sensor flag                   |
| `water_error`       | Water-level sensor flag                 |

| Output Signal   | Description         |
| --------------- | ------------------- |
| `cs[3:0]`       | Current FSM state   |
| `cycleComplete` | Cycle finished flag |

**Modes and Durations**:

| Mode       | Code | Duration (s) |
| ---------- | ---- | ------------ |
| QuickWash  | 000  | 120          |
| Sports     | 001  | 190          |
| GentleCare | 010  | 140          |
| Denim      | 011  | 160          |
| Wool       | 100  | 150          |
| Synthetics | 101  | 230          |

---

## 🧩 State Machine

The FSM consists of 12 states:

```
Idle (0000) → Options (0001) → {Configurations (0010)} → Ready (0011)
       ↓                                      ↓
    Completion (1000)                 CheckForError (1111) → Bamla_Mayya (1001)
                                                  ↓               ↓
                                           Wash (0100) ↔ Drain (0110)
                                                  ↓
                                             Rinse (0101) → Dry (0111)
                                                  ↓
                                              Completion (1000)
```

Error and Pause states handle unexpected conditions before resuming.

---

## 🧪 Simulation & Verification

* **Directed Tests**: Mode selection, timer validity, error conditions
* **Random & Constrained Tests**: Cover edge cases and stability
* **PSL Assertions**: 21 assertions for state transitions and error handling
* **Coverage Metrics**:

  * Assertion Coverage: 100%
  * FSM State Coverage: 100%
  * Transition Coverage: 75%
  * Statement Coverage: 92.3%
  * Branch Coverage: 91.8%
  * Toggle Coverage: 82.4%

Waveforms and logs are available under `waveforms/`.

---


## 🛠 Tools & Environment

* **Verilog HDL**
* **ModelSim/QuestaSim** for simulation
* **PSL** for assertions
* **Waveform Viewer** for RTL analysis

---
