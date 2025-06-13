# Arithmetic Logic Unit (ALU) - Verilog Implementation

## Overview

This project is a hardware-based Arithmetic Logic Unit (ALU) implemented in Verilog.

It performs basic arithmetic operations:
- Addition
- Subtraction
- Multiplication
- Division

All operations are done using hardware logic components, not built-in operators. The system is deployed on an FPGA board.

## Features

- Modular design with a separate Verilog module for each operation
- Central control module to manage operation flow
- Seven-segment display to show:
  - Operand A
  - Operand B
  - Result
- LEDs to show:
  - Sign flag
  - Zero flag
## Components

- Half and Full adder
- Subtractor
- Multiplier
- Divider.v
- `controller.v`: Manages module selection and data flow
- `display.v`: Drives seven-segment displays
- `flags.v`: Generates and manages flag outputs
- `top_module.v`: Instantiates and connects all modules

## FPGA I/O

- Inputs:
  - Switches or buttons to select operation and input operands
- Outputs:
  - 7-segment displays for operands and result
  - LEDs for flags

## Usage

1. Load the bitstream to the FPGA
2. Select operation using input switches
3. Input operands A and B
4. Observe result on seven-segment display
5. Check flag LEDs for:
   - Negative result (Sign)
   - Zero result



