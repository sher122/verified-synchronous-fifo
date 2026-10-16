# Verified Synchronous FIFO

A parameterized synchronous First-In, First-Out (FIFO) buffer implemented in SystemVerilog and verified using Icarus Verilog.

## Overview

This project implements a synchronous FIFO that stores data in order and returns the oldest stored item first. The design uses separate read and write pointers, an occupancy counter, and full/empty status flags.

The project demonstrates RTL design, simulation-based verification, boundary-condition testing, and waveform inspection.
<img width="1164" height="253" alt="image" src="https://github.com/user-attachments/assets/cde65dcf-327b-4842-81c2-698e9dd9ac2a" />

## Design Specifications

| Parameter | Default |
|---|---|
| Data width | 8 bits |
| FIFO depth | 4 entries |
| Clocking | Single clock |
| Reset | Synchronous, active-high |
| Read/write interface | Enable-based |
| Status flags | `full`, `empty` |

### Interface

| Signal | Direction | Description |
|---|---|---|
| `clk` | Input | Clock |
| `rst` | Input | Synchronous active-high reset |
| `wr_en` | Input | Requests a write |
| `din` | Input | Data to write |
| `rd_en` | Input | Requests a read |
| `dout` | Output | Data returned by a read |
| `full` | Output | FIFO has no free entries |
| `empty` | Output | FIFO contains no valid entries |

## Design Behavior

- Data is written only when the FIFO is not full.
- Data is read only when the FIFO is not empty.
- Read and write pointers wrap around the storage array.
- The occupancy counter tracks the number of stored entries.
- A rejected read leaves `dout` unchanged.
- When full, a simultaneous read/write request accepts the read and rejects the write.
- When empty, a simultaneous read/write request accepts the write and rejects the read.
- Reset clears the pointers, occupancy, and output register. The memory array itself is not reset.

## Repository Structure

```text
verified-synchronous-fifo/
├── rtl/
│   └── sync_fifo.sv
├── tb/
│   └── tb_sync_fifo.sv
├── docs/
├── results/
├── .gitignore
└── README.md
```

Simulation executables and waveform files are generated under `results/` and should not be committed unless intentionally included as project artifacts.

## Tools

- SystemVerilog
- Icarus Verilog
- GTKWave
- Git and GitHub
- Visual Studio Code

## Run the Simulation

Run these commands from the repository root in PowerShell.

Compile:

```powershell
iverilog -g2012 -s tb_sync_fifo -o results\tb_sync_fifo.vvp rtl\sync_fifo.sv tb\tb_sync_fifo.sv
```

Run:

```powershell
vvp results\tb_sync_fifo.vvp
```

The testbench also writes a waveform file:

```text
results/fifo_wave.vcd
```

Open it in GTKWave to inspect the clock, reset, enables, data, and status flags.

## Verification

The current testbench exercises these scenarios:

1. Single-value write and read
2. FIFO ordering with multiple values
3. Read request while empty
4. Write request while full
5. Simultaneous read/write while partially filled
6. Simultaneous read/write while full
7. Reset behavior
8. Pointer wraparound and data ordering

**Latest observed simulation result:** all eight named test scenarios passed.

The testbench uses assertions with `$fatal` to stop simulation when checked behavior is incorrect.

## Limitations and Future Improvements

- Expand testing across multiple parameter values, including non-power-of-two depths.
- Add a self-checking reference queue and randomized transactions.
- Improve automated pass/fail reporting for individual assertions.
- Add coverage for reset during active traffic and additional simultaneous-operation cases.
- Consider synthesis checks and linting.

## Learning Outcomes

- Developed a parameterized synchronous FIFO in SystemVerilog.
- Implemented read/write pointers and circular wraparound.
- Used occupancy tracking to derive full and empty status.
- Built a simulation testbench with automated checks.
- Used Icarus Verilog for simulation and GTKWave for waveform inspection.
- Practiced version control with Git.

## Author

**Project:** Verified Synchronous FIFO  
**Purpose:** RTL design and verification portfolio project
