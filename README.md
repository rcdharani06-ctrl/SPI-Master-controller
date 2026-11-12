
# SPI Master Controller

A mini-project implementing an SPI (Serial Peripheral Interface) Master Controller using SystemVerilog.

The design performs 8-bit serial data transmission and reception using a Finite State Machine (FSM).

## 1. Project Overview

The SPI Master Controller communicates with a slave device using four standard SPI signals.

- **MOSI:** Master Out Slave In
- **MISO:** Master In Slave Out
- **SCLK:** Serial Clock
- **CS_N:** Active-low Chip Select

The master initiates communication, generates the serial clock, transmits data through MOSI and receives data through MISO.

## 2. Design Specifications

| Parameter | Description |
|---|---|
| HDL | SystemVerilog |
| Architecture | SPI Master |
| Data Width | 8 bits (default) |
| SPI Mode | Mode 0 |
| Clock Polarity (CPOL) | 0 |
| Clock Phase (CPHA) | 0 |
| Data Order | MSB First |
| Clock Divider | 4 (default) |
| Reset | Active-high asynchronous |
| Control | Finite State Machine |

## 3. Architecture

The controller uses three states:

1. **IDLE:** Waits for a start signal and loads the transmit data.
2. **TRANSFER:** Generates SCLK and performs simultaneous data transmission and reception.
3. **FINISH:** Deactivates chip select and indicates transaction completion.

### State Transition

IDLE → TRANSFER → FINISH → IDLE

## 4. SPI Mode 0 Operation

This project implements SPI Mode 0.

- SCLK remains LOW when idle.
- MOSI data changes on falling SCLK edges.
- MISO data is sampled on rising SCLK edges.
- Data is transmitted MSB first.
- CS_N is LOW during communication.

## 5. Project Structure

```text
SPI_Master_Controller/
│
├── rtl/
│   └── spi_master.sv
│
├── testbench/
│   └── tb_spi_master.sv
│
├── docs/
│   └── waveform.png
│
├── README.md
└── .gitignore
```

## 6. Simulation and Verification

The testbench models an SPI slave and checks the master controller.

### Test Configuration

| Signal | Value |
|---|---|
| Master Transmit Data | 0xA5 |
| Slave Response | 0x3C |
| Data Width | 8 bits |
| Clock Divider | 4 |

### Verification Checks

- Transmitted data correctness
- Received data correctness
- Number of transmitted bits
- Busy signal deassertion
- Chip select deassertion
- SCLK returns to idle LOW
- Completion pulse clears correctly
- Transaction timeout protection

### Simulation Waveform

![SPI Master Simulation Waveform](docs/waveform.png)

The supplied waveform shows:

- TX data: 165 decimal (0xA5)
- RX data: 60 decimal (0x3C)

## 7. Simulation

The project can be simulated using EDA Playground with a compatible SystemVerilog simulator.

[Open SPI Master Simulation on EDA Playground](https://edaplayground.com/x/kaMC)

For local simulation using Icarus Verilog:

```bash
iverilog -g2012 -s tb_spi_master -o spi_sim rtl/spi_master.sv testbench/tb_spi_master.sv
vvp spi_sim
```

The testbench generates `dump.vcd` for waveform viewing.

## 8. Design Limitations

- The current implementation supports SPI Mode 0 only.
- The supplied testbench verifies an 8-bit transaction.
- The design's shift-register part-selects require DATA_WIDTH >= 2.
- CLK_DIV must be greater than or equal to 1.
- The testbench models a simple slave and does not represent a physical SPI peripheral.

## 9. Future Improvements

- Support for SPI Modes 1, 2 and 3.
- Configurable slave selection.
- Back-to-back data transfers.
- Additional parameterized-width verification.
- FPGA implementation and hardware validation.

---

**Project Category:** Digital Design / RTL Design

**Language:** SystemVerilog
