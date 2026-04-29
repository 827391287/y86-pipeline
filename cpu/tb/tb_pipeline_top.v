`timescale 1ns/1ps
`include "define.v"

// ============================================================
// Generic testbench for RV32I 5-stage pipeline
// All tests report results via PASS/FAIL counters at dmem
// addresses 0x2000 / 0x2004 (written by the C test program).
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
        $display("[%3d] F_pc=%h | D_op=%h | E_pc=%h | M_rd=%0d | W_stat=%0d | stall=%b%b bubble=%b%b%b",
            cycle,
            dut.f_pc,
            dut.D_instr[6:0],
            dut.E_pc,
            dut.M_rd,
            dut.W_stat,
            dut.F_stall, dut.D_stall,
            dut.E_bubble, dut.M_bubble, dut.W_bubble
        );
    end

    // ---- halt: read PASS/FAIL from dmem and finish ----
    // C tests write results to:
    //   0x2000 : pass count (32-bit little-endian)
    //   0x2004 : fail count (32-bit little-endian)
    integer pass_count, fail_count;
    always @(posedge clk) begin
        if (halt) begin
            pass_count = {dut.dmem_inst.mem[32'h2003],
                          dut.dmem_inst.mem[32'h2002],
                          dut.dmem_inst.mem[32'h2001],
                          dut.dmem_inst.mem[32'h2000]};
            fail_count = {dut.dmem_inst.mem[32'h2007],
                          dut.dmem_inst.mem[32'h2006],
                          dut.dmem_inst.mem[32'h2005],
                          dut.dmem_inst.mem[32'h2004]};

            $display("");
            $display("=== HALT at cycle %0d ===", cycle);
            $display("  PASS : %0d", pass_count);
            $display("  FAIL : %0d", fail_count);
            if (fail_count == 0)
                $display("*** PASS: all %0d checks passed ***", pass_count);
            else
                $display("*** FAIL: %0d error(s) out of %0d ***",
                         fail_count, pass_count + fail_count);

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
