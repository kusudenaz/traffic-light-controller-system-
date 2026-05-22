# Traffic Light Controller System

This project is a traffic light controller system designed for the COMP2001 Digital Design course. The system was first designed in Logisim and then implemented in Verilog.

## Project Description

The aim of this project is to control traffic lights for four directions:

- East
- West
- North
- South

Each direction has three lights:

- Red
- Yellow
- Green

The controller allows only one direction to move at a time. While one direction is active, the other directions remain red for safety.

## System Design

The system is based on a finite state machine (FSM). The FSM controls the active direction and the current traffic light phase.

The main phases are:

- PRE phase: yellow light before green
- GREEN phase: active direction can move
- POST phase: yellow light after green

After reset, the system starts with a safe initialization step where all lights are red.

## Timing Parameters

| Phase | Duration |
|---|---:|
| Yellow light | 2 seconds |
| Main road green light | 20 seconds |
| Side road green light | 15 seconds |

## Files in This Repository

```text
Traffic_Light_Controller_Report.docx
README.md
logisim-circuit-1.jpeg
logisim-circuit-2.jpeg

verilog/
  traffic_controller_1hz.v
  tb_traffic_controller_1hz_fast.v
Verilog Files
traffic_controller_1hz.v contains the main traffic light controller module.
tb_traffic_controller_1hz_fast.v contains the testbench used for simulation.
Simulation

The testbench uses faster simulation timing. In the simulation, 1 second is represented as 10 ns to make the testing process faster.

The testbench checks:

Reset behavior
Direction changes
Phase transitions
Traffic light outputs
Safe all-red initialization
Logisim Design

The Logisim circuit was used as the reference design for the controller logic. The design includes the counter logic, decoders, state logic, and output control circuits.

Authors
Esma Begüm Demir
Eda Eylül Özdemir
Sudenaz Kuş
Course Information

Course: COMP2001 Digital Design
Department: Computer Engineering
University: Konya Food and Agriculture University
Instructor: Prof. Dr. Kasım Öztoprak
