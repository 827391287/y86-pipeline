`timescale 1ns/1ps
`include "define.v"

// ============================================================
// Top-level testbench for RV32I 5-stage pipeline
// Usage: compile with -I cpu/rtl -I cpu/tb
//        run: vvp sim.vvp
// ============================================================
module tb_pipeline_top;

    // ---- clock & reset ----
    reg clk, rst_n;
    initial clk = 0;
    always #5 clk = ~clk;   // 10 ns period = 100 MHz

    initial begin
        rst_n = 0;
        repeat(2) @(posedge clk);
        #1 rst_n = 1;
    end

    // ---- DUT ----
    wire halt;
    pipeline_top dut (
        .clk   (clk),
        .rst_n (rst_n),
        .halt  (halt)
    );

    // ---- waveform dump ----
    initial begin
        $dumpfile("sim.vcd");
        $dumpvars(0, tb_pipeline_top);
    end

    // ---- cycle counter ----
    integer cycle;
    initial cycle = 0;
    always @(posedge clk) #1 cycle = cycle + 1;

    // ---- per-cycle pipeline state ----
    always @(posedge clk) begin
        #1;
        $display("[%3d] F_pc=%h | D=%h | E=%h | M=%h | W_stat=%0d | x1=%0d x2=%0d x3=%0d x4=%0d | stall=%b%b bubble=%b%b%b",
            cycle,
            dut.f_pc,
            dut.D_instr[6:0],   // opcode at D
            dut.E_pc,
            dut.M_rd,
            dut.W_stat,
            $signed(dut.regfile_inst.mem[1]),
            $signed(dut.regfile_inst.mem[2]),
            $signed(dut.regfile_inst.mem[3]),
            $signed(dut.regfile_inst.mem[4]),
            dut.F_stall, dut.D_stall,
            dut.E_bubble, dut.M_bubble, dut.W_bubble
        );
    end

    // ---- halt: self-check & finish ----
    // Expected values are set per test program — update when switching programs
    integer errors;
    always @(posedge clk) begin
        if (halt) begin
            errors = 0;
            $display("");
            $display("=== HALT at cycle %0d ===", cycle);
            $display("Register file dump:");
            $display("  x1  = %0d", $signed(dut.regfile_inst.mem[1]));
            $display("  x2  = %0d", $signed(dut.regfile_inst.mem[2]));
            $display("  x3  = %0d", $signed(dut.regfile_inst.mem[3]));
            $display("  x4  = %0d", $signed(dut.regfile_inst.mem[4]));
            $display("  x5  = %0d", $signed(dut.regfile_inst.mem[5]));
            $display("  x6  = %0d", $signed(dut.regfile_inst.mem[6]));
            $display("  x7  = %0d", $signed(dut.regfile_inst.mem[7]));
            $display("  x8  = %0d", $signed(dut.regfile_inst.mem[8]));
            $display("  x10 = %0d", $signed(dut.regfile_inst.mem[10]));
            $display("");

            // ---- expected values for test_alu ----
            `CHECK(1,  32'd10,  "addi x1=10")
            `CHECK(2,  32'd7,   "addi x2=7")
            `CHECK(3,  32'd17,  "add  x3=x1+x2")
            `CHECK(4,  32'd3,   "sub  x4=x1-x2")
            `CHECK(5,  32'd2,   "and  x5=x1&x2")
            `CHECK(6,  32'd15,  "or   x6=x1|x2")
            `CHECK(7,  32'd13,  "xor  x7=x1^x2")

            if (errors == 0)
                $display("*** PASS: all %0d checks passed ***", 7);
            else
                $display("*** FAIL: %0d error(s) ***", errors);

            #20 $finish;
        end
    end

    // ---- timeout guard ----
    initial begin
        #5000;
        $display("[TIMEOUT] No halt after 500 cycles — check imem/dmem files");
        $finish;
    end

endmodule

// ---- self-check macro ----
`define CHECK(REG, EXP, MSG) \
    if (dut.regfile_inst.mem[REG] !== EXP) begin \
        $display("  FAIL %-20s : got %0d, expected %0d", MSG, \
                 $signed(dut.regfile_inst.mem[REG]), $signed(EXP)); \
        errors = errors + 1; \
    end else begin \
        $display("  PASS %-20s : %0d", MSG, $signed(EXP)); \
    end
