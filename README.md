# Y86-64 Five-Stage Pipeline CPU

A synthesizable 5-stage pipelined CPU implementation based on the Y86-64 ISA, written in Verilog.

## Architecture

The pipeline consists of five stages:

| Stage | Module | Function |
|-------|--------|----------|
| Fetch (F) | `fetch.v` | Instruction fetch, PC prediction |
| Decode (D) | `decode.v` | Register read, operand selection |
| Execute (E) | `execute.v` | ALU operations, branch evaluation |
| Memory (M) | `memory.v` | Data memory read/write |
| Writeback (W) | `writeback.v` | Register file write |

## Features

- **Data Forwarding**: Resolves RAW hazards by forwarding results from E/M/W stages back to D stage
- **Hazard Detection**: Detects load-use hazards and inserts stalls automatically
- **Branch Handling**: Detects mispredictions and flushes the pipeline (2-cycle penalty)
- **Exception Handling**: Detects invalid instructions and memory address errors

## Supported Instructions

| Opcode | Instruction | Description |
|--------|-------------|-------------|
| `0x00` | `halt` | Halt execution |
| `0x10` | `nop` | No operation |
| `0x20` | `rrmovq` | Register-to-register move |
| `0x30` | `irmovq` | Immediate-to-register move |
| `0x40` | `rmmovq` | Register-to-memory |
| `0x50` | `mrmovq` | Memory-to-register |
| `0x60` | `OPq` | ALU operations (add/sub/and/xor) |
| `0x70` | `jXX` | Conditional jumps |
| `0x80` | `call` | Function call |
| `0x90` | `ret` | Function return |
| `0xA0` | `pushq` | Push to stack |
| `0xB0` | `popq` | Pop from stack |

## File Structure

```
├── define.v                    # ISA constants and macro definitions
├── fetch.v                     # Fetch stage
├── decode.v                    # Decode stage
├── execute.v                   # Execute stage
├── memory.v                    # Memory access stage
├── writeback.v                 # Writeback stage
├── controller.v                # Hazard detection and pipeline control
├── sel_fwd.v                   # Data forwarding logic
├── select_pc.v                 # PC selection logic
├── F_pipe_reg.v                # Fetch stage pipeline register
├── fetch_D_pipe_reg.v          # Fetch-to-Decode pipeline register
├── decode_E_pipe_reg.v         # Decode-to-Execute pipeline register
├── execute_M_pipe_reg.v        # Execute-to-Memory pipeline register
├── memory_access_W_pipe_reg.v  # Memory-to-Writeback pipeline register
└── fetch_tb.v                  # Testbench
```

## Simulation

This project uses ModelSim for simulation.

1. Open ModelSim and load `instruction pipelining.mpf`
2. Compile all source files
3. Run `fetch_tb` as the top-level simulation module
