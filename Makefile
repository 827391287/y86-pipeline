# ============================================================
# RV32I Pipeline CPU — Simulation Makefile (QuestaSim)
# ============================================================
# Usage:
#   make sim              # simulate with default test (alu)
#   make sim TEST=foo     # simulate cpu/tb/tests/foo/test.mem
#   make c   TEST=foo     # compile foo/test.c → foo/test.mem, then simulate
#   make compile          # RTL compile only
#   make clean            # remove build artifacts
# ============================================================

# ---- directories ----
RTL_DIR  := cpu/rtl
TB_DIR   := cpu/tb
TST_DIR  := cpu/tb/tests
CMN_DIR  := $(TST_DIR)/common

# ---- test selection ----
TEST     ?= alu
TEST_DIR := $(TST_DIR)/$(TEST)
C_SRC    := $(TEST_DIR)/test.c
ELF      := $(TEST_DIR)/test.elf
BIN      := $(TEST_DIR)/test.bin
MEM      := $(TEST_DIR)/test.mem

# ---- RTL source list ----
RTL_SRCS := \
	$(RTL_DIR)/pipeline_top.v       \
	$(RTL_DIR)/fetch.v              \
	$(RTL_DIR)/F_pipe_reg.v         \
	$(RTL_DIR)/fetch_D_pipe_reg.v   \
	$(RTL_DIR)/regfile.v            \
	$(RTL_DIR)/sel_fwd.v            \
	$(RTL_DIR)/decode.v             \
	$(RTL_DIR)/decode_E_pipe_reg.v  \
	$(RTL_DIR)/execute.v            \
	$(RTL_DIR)/execute_M_pipe_reg.v \
	$(RTL_DIR)/imem.v               \
	$(RTL_DIR)/dmem.v               \
	$(RTL_DIR)/memory.v             \
	$(RTL_DIR)/memory_W_pipe_reg.v  \
	$(RTL_DIR)/writeback.v          \
	$(RTL_DIR)/select_pc.v          \
	$(RTL_DIR)/controller.v

TB_SRCS := $(TB_DIR)/tb_pipeline_top.v
TESTCFG := $(TB_DIR)/test_config.v

# ============================================================
.PHONY: all sim c compile clean dump gui

all: sim

# ---- step 1: compile C source to .mem ----
c:
	@echo "[CC]      $(C_SRC) → $(ELF)"
	riscv-none-elf-gcc -march=rv32i -mabi=ilp32 -nostdlib -O1 -g \
	  -T $(CMN_DIR)/link.ld $(CMN_DIR)/crt0.s $(C_SRC) -o $(ELF)
	@echo "[OBJCOPY] $(ELF) → $(BIN)"
	riscv-none-elf-objcopy -O binary $(ELF) $(BIN)
	@echo "[BIN2MEM] $(BIN) → $(MEM)"
	python tools/bin2mem.py $(BIN) $(MEM)
	make sim TEST=$(TEST)

# ---- step 2: write test_config.v to select which .mem file to load ----
$(TESTCFG):
	@echo "[CFG]     Selecting test: $(TEST)"
	@echo '`define PROG_FILE "$(TEST_DIR)/test.mem"' > $(TESTCFG)
	@echo '`define DATA_FILE "$(CMN_DIR)/data.mem"'  >> $(TESTCFG)

# ---- step 3: compile RTL with QuestaSim ----
compile: $(TESTCFG)
	@echo "[VLOG]    Compiling RTL..."
	vlib work
	vlog -work work \
	  +incdir+$(RTL_DIR) \
	  +incdir+$(TB_DIR)  \
	  $(RTL_SRCS) $(TB_SRCS)
	@echo "[VLOG]    Done"

# ---- step 4: run simulation ----
sim: compile
	@echo "[VSIM]    Running $(TEST)..."
	@echo "--------------------------------------------"
	vsim -voptargs="+acc" -c tb_pipeline_top -do "log -r /*; run -all; quit"
	@echo "--------------------------------------------"

dump:
	riscv-none-elf-objdump -d $(TST_DIR)/$(TEST)/test.elf

# ---- interactive GUI mode (full hierarchy + live signals) ----
gui:
	vsim -voptargs="+acc" tb_pipeline_top -do "log -r /*"

# ---- clean build artifacts ----
clean:
	rm -rf work/
	rm -f  $(TST_DIR)/*/*.elf
	rm -f  $(TST_DIR)/*/*.bin
	rm -f  $(TESTCFG)
	rm -f  vsim.wlf transcript
