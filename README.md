# RV32I Five-Stage Pipeline CPU

A synthesizable 5-stage pipelined CPU implementing the **RISC-V RV32I** base integer ISA, written in Verilog.

Migrated from a Y86-64 prototype to RV32I with full hazard handling, data forwarding, and Harvard memory architecture.

## Architecture

```
      ┌──────┐   ┌──────┐   ┌──────┐   ┌──────┐   ┌──────┐
 ───► │  F   │──►│  D   │──►│  E   │──►│  M   │──►│  W   │
      │Fetch │   │Decode│   │ ALU  │   │ Mem  │   │ WB   │
      └──────┘   └──────┘   └──────┘   └──────┘   └──────┘
         ▲           ▲           │           │           │
         │           └───────────┴───────────┘           │
         │              Data Forwarding (E/M/W → D)      │
         │                                               │
      select_pc ◄── branch_taken / jalr_target (from E) │
                                                         ▼
                                                      regfile
```

### Pipeline Stages

| Stage | Module | Function |
|-------|--------|----------|
| Fetch (F) | `fetch.v` | Instruction fetch, static JAL prediction |
| Decode (D) | `decode.v` + `sel_fwd.v` | Decode, register read, forwarding mux |
| Execute (E) | `execute.v` | ALU, branch compare, JALR target |
| Memory (M) | `memory.v` | Load/store, byte/half/word, misalign detect |
| Writeback (W) | `writeback.v` | Register file write (dual-port: ALU + LOAD) |

## Features

### Hazard Handling

| Hazard | Detection | Resolution |
|--------|-----------|------------|
| RAW (non-load) | Forwarding network | Forward E/M/W → D, 0-cycle penalty |
| Load-use | `E_mem_re && E_rd_m == d_rs1/rs2` | Stall F+D, bubble E, 1-cycle penalty |
| Branch taken | `branch_taken_o` from execute | Bubble E (flush wrong fetch), 1-cycle penalty |
| JALR | `E_jalr` + `e_jalr_target` | Bubble E (flush wrong fetch), 1-cycle penalty |
| JAL | Static prediction in fetch | PC = PC + imm_J, **0-cycle penalty** |
| Exception | Stat propagation | Bubble M when exception reaches M, stall W |

### Data Forwarding

- **E→D**: ALU result from execute forwarded to decode in the same cycle
- **M→D (ALU)**: M-stage register value forwarded to decode
- **M→D (LOAD)**: Combinational dmem read result forwarded to decode
- **W→D**: W-stage register value forwarded to decode

### Memory

- **Harvard architecture**: Separate `imem.v` (instruction) and `dmem.v` (data)
- **Sub-word access**: LB / LH / LW / LBU / LHU, SB / SH / SW
- **Byte-enable writes**: Byte-level write enables for sub-word stores
- **Misalignment detection**: Raises `SADR` exception for misaligned LW/LH/SW/SH

## Supported Instructions

| Category | Instructions |
|----------|-------------|
| ALU (R-type) | ADD, SUB, AND, OR, XOR, SLL, SRL, SRA, SLT, SLTU |
| ALU Immediate | ADDI, ANDI, ORI, XORI, SLLI, SRLI, SRAI, SLTI, SLTIU |
| Load | LW, LH, LB, LHU, LBU |
| Store | SW, SH, SB |
| Branch | BEQ, BNE, BLT, BGE, BLTU, BGEU |
| Jump | JAL, JALR |
| Upper Immediate | LUI, AUIPC |
| System | EBREAK (halt) |

## File Structure

```
├── cpu/
│   ├── rtl/                        # RTL source files
│   │   ├── define.v                # ISA constants, ABI register aliases
│   │   ├── pipeline_top.v          # Top-level: connects all modules
│   │   ├── fetch.v                 # F stage: fetch + static JAL prediction
│   │   ├── F_pipe_reg.v            # F pipeline register (holds predPC)
│   │   ├── fetch_D_pipe_reg.v      # F→D pipeline register
│   │   ├── regfile.v               # 32×32-bit register file (dual write port)
│   │   ├── sel_fwd.v               # rs1/rs2 forwarding mux (sel_fwd + fwd)
│   │   ├── decode.v                # D stage: decode + forwarding
│   │   ├── decode_E_pipe_reg.v     # D→E pipeline register
│   │   ├── execute.v               # E stage: ALU, branch, JALR
│   │   ├── execute_M_pipe_reg.v    # E→M pipeline register
│   │   ├── imem.v                  # Instruction memory (64 KB, byte-addressed)
│   │   ├── dmem.v                  # Data memory (64 KB, byte-enable write)
│   │   ├── memory.v                # M stage: load/store, misalign detect
│   │   ├── memory_W_pipe_reg.v     # M→W pipeline register
│   │   ├── writeback.v             # W stage: pass-through to regfile
│   │   ├── select_pc.v             # PC mux: redirect / predict
│   │   └── controller.v            # Hazard controller: stall/bubble signals
│   └── tb/                         # Verification
│       ├── tb_pipeline_top.v       # Self-checking testbench
│       ├── test_config.v           # Switch test program (PROG_FILE / DATA_FILE)
│       └── tests/
│           ├── test_alu.mem        # Basic ALU test
│           └── data.mem            # Data memory initialization
├── sim/
│   └── run.bat                     # One-shot compile + simulate (Windows)
└── tools/
    └── bin2mem.py                  # RISC-V binary → $readmemh converter
```

## Simulation

### Requirements

- [Icarus Verilog](https://bleyer.org/icarus/) (`iverilog` / `vvp`)
- Optional: [GTKWave](https://gtkwave.sourceforge.net/) for waveform viewing

### Run

```bat
:: From project root (Windows)
sim\run.bat test_alu
```

The testbench auto-checks register values and prints PASS / FAIL.

### Writing Test Programs

For simple tests, hand-assemble instructions into `.mem` files (one byte per line, little-endian). For larger programs, use the RISC-V toolchain:

```bash
# Assemble
riscv-none-elf-gcc -march=rv32i -mabi=ilp32 -nostdlib -Wl,-Ttext=0x0 prog.s -o prog.elf

# Extract binary and convert to mem format
riscv-none-elf-objcopy -O binary prog.elf prog.bin
python tools/bin2mem.py prog.bin cpu/tb/tests/test_xxx.mem

# Run
sim\run.bat test_xxx
```

Switch test programs by editing `cpu/tb/test_config.v` or passing a name to `run.bat`.

## Roadmap

- [x] RV32I base ISA
- [x] 5-stage pipeline with full hazard handling
- [x] Data forwarding (E/M/W → D)
- [x] Self-checking simulation testbench
- [ ] UVM verification environment
- [ ] Cache (I-cache / D-cache)
- [ ] AXI4 bus interface
