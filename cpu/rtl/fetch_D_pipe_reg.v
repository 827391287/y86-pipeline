`include "define.v"

// F→D 流水线寄存器
// RV32I 的指令解码在 D 级完成，所以这里只携带原始指令
module fetch_D_pipe_reg(
    input  wire        clk_i,
    input  wire        D_stall_i,
    input  wire        D_bubble_i,

    input  wire [2:0]  f_stat_i,
    input  wire [31:0] f_pc_i,
    input  wire [31:0] f_instr_i,   // 原始32位指令
    input  wire [31:0] f_valP_i,    // PC+4，作为 JAL/JALR 链接地址

    output wire [2:0]  D_stat_o,
    output wire [31:0] D_pc_o,
    output wire [31:0] D_instr_o,
    output wire [31:0] D_valP_o
);

    reg [2:0]  D_stat_tp;
    reg [31:0] D_pc_tp;
    reg [31:0] D_instr_tp;
    reg [31:0] D_valP_tp;

    // NOP = ADDI x0, x0, 0 = 32'h0000_0013
    localparam NOP = 32'h00000013;

    initial begin
        D_stat_tp  = `SAOK;
        D_pc_tp    = 32'h0;
        D_instr_tp = NOP;
        D_valP_tp  = 32'h0;
    end

    always @(posedge clk_i) begin
        if (D_bubble_i) begin
            D_stat_tp  <= `SAOK;
            D_pc_tp    <= 32'h0;
            D_instr_tp <= NOP;
            D_valP_tp  <= 32'h0;
        end
        else if (~D_stall_i) begin
            D_stat_tp  <= f_stat_i;
            D_pc_tp    <= f_pc_i;
            D_instr_tp <= f_instr_i;
            D_valP_tp  <= f_valP_i;
        end
    end

    assign D_stat_o  = D_stat_tp;
    assign D_pc_o    = D_pc_tp;
    assign D_instr_o = D_instr_tp;
    assign D_valP_o  = D_valP_tp;

endmodule
