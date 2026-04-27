`include "define.v"

// rs1 前递模块
// 优先级：JAL 特例 > e > M_alu > M_load > W_alu > W_load > 寄存器堆
module sel_fwd(
    input  wire [6:0]  opcode_i,
    input  wire [31:0] valP_i,        // JAL 链接值（PC+4）

    input  wire [4:0]  rs1_i,         // 当前指令 rs1

    input  wire [4:0]  e_rd_i,
    input  wire [31:0] e_rd_val_i,

    input  wire [4:0]  M_rd_i,
    input  wire [31:0] M_rd_val_i,

    input  wire [4:0]  M_rd_m_i,
    input  wire [31:0] m_rd_m_val_i,

    input  wire [4:0]  W_rd_i,
    input  wire [31:0] W_rd_val_i,

    input  wire [4:0]  W_rd_m_i,
    input  wire [31:0] W_rd_m_val_i,

    input  wire [31:0] rvalA_i,       // 寄存器堆直接读出值

    output wire [31:0] rs1_val_o
);

assign rs1_val_o =
    (opcode_i == `OP_JAL)                                  ? valP_i       :
    (rs1_i != 5'd0 && rs1_i == e_rd_i)                    ? e_rd_val_i   :
    (rs1_i != 5'd0 && rs1_i == M_rd_i)                    ? M_rd_val_i   :
    (rs1_i != 5'd0 && rs1_i == M_rd_m_i)                  ? m_rd_m_val_i :
    (rs1_i != 5'd0 && rs1_i == W_rd_i)                    ? W_rd_val_i   :
    (rs1_i != 5'd0 && rs1_i == W_rd_m_i)                  ? W_rd_m_val_i :
                                                             rvalA_i;

endmodule


// rs2 前递模块
module fwd(
    input  wire [4:0]  rs2_i,

    input  wire [4:0]  e_rd_i,
    input  wire [31:0] e_rd_val_i,

    input  wire [4:0]  M_rd_i,
    input  wire [31:0] M_rd_val_i,

    input  wire [4:0]  M_rd_m_i,
    input  wire [31:0] m_rd_m_val_i,

    input  wire [4:0]  W_rd_i,
    input  wire [31:0] W_rd_val_i,

    input  wire [4:0]  W_rd_m_i,
    input  wire [31:0] W_rd_m_val_i,

    input  wire [31:0] rvalB_i,

    output wire [31:0] rs2_val_o
);

assign rs2_val_o =
    (rs2_i != 5'd0 && rs2_i == e_rd_i)                    ? e_rd_val_i   :
    (rs2_i != 5'd0 && rs2_i == M_rd_i)                    ? M_rd_val_i   :
    (rs2_i != 5'd0 && rs2_i == M_rd_m_i)                  ? m_rd_m_val_i :
    (rs2_i != 5'd0 && rs2_i == W_rd_i)                    ? W_rd_val_i   :
    (rs2_i != 5'd0 && rs2_i == W_rd_m_i)                  ? W_rd_m_val_i :
                                                             rvalB_i;

endmodule
