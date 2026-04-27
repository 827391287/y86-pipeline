@echo off
:: ============================================================
:: RV32I Pipeline Simulation Script (Windows / Icarus Verilog)
:: Run from project root: sim\run.bat [test_name]
:: Example: sim\run.bat test_alu
:: ============================================================

set RTL=cpu\rtl
set TB=cpu\tb
set TEST=%1
if "%TEST%"=="" set TEST=test_alu

:: Update test_config.v to point to the selected test
echo `define PROG_FILE "cpu/tb/tests/%TEST%.mem"  > %TB%\test_config.v
echo `define DATA_FILE "cpu/tb/tests/data.mem"   >> %TB%\test_config.v

echo [SIM] Compiling test: %TEST%

iverilog -g2012 ^
  -I %RTL% ^
  -I %TB% ^
  %RTL%\pipeline_top.v ^
  %RTL%\fetch.v ^
  %RTL%\F_pipe_reg.v ^
  %RTL%\fetch_D_pipe_reg.v ^
  %RTL%\regfile.v ^
  %RTL%\sel_fwd.v ^
  %RTL%\decode.v ^
  %RTL%\decode_E_pipe_reg.v ^
  %RTL%\execute.v ^
  %RTL%\execute_M_pipe_reg.v ^
  %RTL%\imem.v ^
  %RTL%\dmem.v ^
  %RTL%\memory.v ^
  %RTL%\memory_W_pipe_reg.v ^
  %RTL%\writeback.v ^
  %RTL%\select_pc.v ^
  %RTL%\controller.v ^
  %TB%\tb_pipeline_top.v ^
  -o sim\sim.vvp

if %ERRORLEVEL% neq 0 (
    echo [ERROR] Compilation failed
    exit /b 1
)

echo [SIM] Running simulation...
vvp sim\sim.vvp

echo [SIM] Done. Waveform: sim.vcd  (open with GTKWave)
