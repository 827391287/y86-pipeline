`include "define.v"

// E→M 流水线寄存器
// 输入前缀 e_：来自 execute 输出
// 输出前缀 M_：送往 memory 及前递网络
module execute_M_pipe_reg(
    input  wire        clk_i,
    input  wire        M_stall_i,
    input  wire        M_bubble_i,

    input  wire [2:0]  e_stat_i,
    input  wire [31:0] e_pc_i,
    input  wire [4:0]  e_rd_i,
    input  wire [4:0]  e_rd_m_i,
    input  wire [31:0] e_rd_val_i,
    input  wire [31:0] e_rs2_val_i,
    input  wire        e_mem_re_i,
    input  wire        e_mem_we_i,
    input  wire [2:0]  e_mem_width_i,

    output wire [2:0]  M_stat_o,
    output wire [31:0] M_pc_o,
    output wire [4:0]  M_rd_o,
    output wire [4:0]  M_rd_m_o,
    output wire [31:0] M_rd_val_o,
    output wire [31:0] M_rs2_val_o,
    output wire        M_mem_re_o,
    output wire        M_mem_we_o,
    output wire [2:0]  M_mem_width_o
);

    reg [2:0]  M_stat_r;
    reg [31:0] M_pc_r;
    reg [4:0]  M_rd_r;
    reg [4:0]  M_rd_m_r;
    reg [31:0] M_rd_val_r;
    reg [31:0] M_rs2_val_r;
    reg        M_mem_re_r;
    reg        M_mem_we_r;
    reg [2:0]  M_mem_width_r;

    initial begin
        M_stat_r      = `SAOK;
        M_pc_r        = 32'h0;
        M_rd_r        = 5'd0;
        M_rd_m_r      = 5'd0;
        M_rd_val_r    = 32'h0;
        M_rs2_val_r   = 32'h0;
        M_mem_re_r    = 1'b0;
        M_mem_we_r    = 1'b0;
        M_mem_width_r = 3'h0;
    end

    always @(posedge clk_i) begin
        if (M_bubble_i) begin
            M_stat_r      <= e_stat_i;
            M_pc_r        <= 32'h0;
            M_rd_r        <= 5'd0;
            M_rd_m_r      <= 5'd0;
            M_rd_val_r    <= 32'h0;
            M_rs2_val_r   <= 32'h0;
            M_mem_re_r    <= 1'b0;
            M_mem_we_r    <= 1'b0;
            M_mem_width_r <= 3'h0;
        end
        else if (~M_stall_i) begin
            M_stat_r      <= e_stat_i;
            M_pc_r        <= e_pc_i;
            M_rd_r        <= e_rd_i;
            M_rd_m_r      <= e_rd_m_i;
            M_rd_val_r    <= e_rd_val_i;
            M_rs2_val_r   <= e_rs2_val_i;
            M_mem_re_r    <= e_mem_re_i;
            M_mem_we_r    <= e_mem_we_i;
            M_mem_width_r <= e_mem_width_i;
        end
    end

    assign M_stat_o      = M_stat_r;
    assign M_pc_o        = M_pc_r;
    assign M_rd_o        = M_rd_r;
    assign M_rd_m_o      = M_rd_m_r;
    assign M_rd_val_o    = M_rd_val_r;
    assign M_rs2_val_o   = M_rs2_val_r;
    assign M_mem_re_o    = M_mem_re_r;
    assign M_mem_we_o    = M_mem_we_r;
    assign M_mem_width_o = M_mem_width_r;

endmodule
