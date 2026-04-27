`include "define.v"

// W 级：纯组合逻辑
// 将 W 寄存器的数据透传给 regfile 写口和前递网络
// 实际写回由 regfile 的时序写口完成（在 pipeline_top 连线）
module writeback(
    input  wire [2:0]  stat_i,
    input  wire [4:0]  rd_i,
    input  wire [31:0] rd_val_i,
    input  wire [4:0]  rd_m_i,
    input  wire [31:0] rd_m_val_i,

    // 送往 regfile 写口（pipeline_top 连线）
    output wire [4:0]  rd_o,
    output wire [31:0] rd_val_o,
    output wire [4:0]  rd_m_o,
    output wire [31:0] rd_m_val_o,

    // 送往 controller / pipeline_top
    output wire [2:0]  stat_o
);

    assign rd_o      = rd_i;
    assign rd_val_o  = rd_val_i;
    assign rd_m_o    = rd_m_i;
    assign rd_m_val_o = rd_m_val_i;
    assign stat_o    = stat_i;

endmodule
