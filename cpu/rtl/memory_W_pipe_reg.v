`include "define.v"

// M→W 流水线寄存器
// 输入前缀 m_ / M_：来自 memory_access 输出 或 execute_M_pipe_reg 直传
// 输出前缀 W_：送往 writeback / regfile 及前递网络
module memory_W_pipe_reg(
    input  wire        clk_i,
    input  wire        W_stall_i,
    input  wire        W_bubble_i,

    // 来自 memory_access（m_ 前缀）
    input  wire [2:0]  m_stat_i,
    input  wire [31:0] m_rd_m_val_i,   // LOAD 结果（符号扩展后）

    // 来自 execute_M_pipe_reg 直传（M_ 前缀）
    input  wire [31:0] M_pc_i,
    input  wire [4:0]  M_rd_i,         // ALU 结果写回目标
    input  wire [31:0] M_rd_val_i,     // ALU 结果
    input  wire [4:0]  M_rd_m_i,       // LOAD 写回目标

    output wire [2:0]  W_stat_o,
    output wire [31:0] W_pc_o,
    output wire [4:0]  W_rd_o,
    output wire [31:0] W_rd_val_o,
    output wire [4:0]  W_rd_m_o,
    output wire [31:0] W_rd_m_val_o
);

    reg [2:0]  W_stat_r;
    reg [31:0] W_pc_r;
    reg [4:0]  W_rd_r;
    reg [31:0] W_rd_val_r;
    reg [4:0]  W_rd_m_r;
    reg [31:0] W_rd_m_val_r;

    initial begin
        W_stat_r     = `SAOK;
        W_pc_r       = 32'h0;
        W_rd_r       = 5'd0;
        W_rd_val_r   = 32'h0;
        W_rd_m_r     = 5'd0;
        W_rd_m_val_r = 32'h0;
    end

    always @(posedge clk_i) begin
        if (W_bubble_i) begin
            W_stat_r     <= m_stat_i;
            W_pc_r       <= 32'h0;
            W_rd_r       <= 5'd0;
            W_rd_val_r   <= 32'h0;
            W_rd_m_r     <= 5'd0;
            W_rd_m_val_r <= 32'h0;
        end
        else if (~W_stall_i) begin
            W_stat_r     <= m_stat_i;
            W_pc_r       <= M_pc_i;
            W_rd_r       <= M_rd_i;
            W_rd_val_r   <= M_rd_val_i;
            W_rd_m_r     <= M_rd_m_i;
            W_rd_m_val_r <= m_rd_m_val_i;
        end
    end

    assign W_stat_o     = W_stat_r;
    assign W_pc_o       = W_pc_r;
    assign W_rd_o       = W_rd_r;
    assign W_rd_val_o   = W_rd_val_r;
    assign W_rd_m_o     = W_rd_m_r;
    assign W_rd_m_val_o = W_rd_m_val_r;

endmodule
