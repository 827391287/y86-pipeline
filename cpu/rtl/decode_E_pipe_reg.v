`include "define.v"

// D→E 流水线寄存器
// 输入前缀 d_：来自 D 级（decode 输出）
// 输出前缀 E_：送往 E 级（execute 输入）
module decode_E_pipe_reg(
    input  wire        clk_i,
    input  wire        E_stall_i,
    input  wire        E_bubble_i,

    input  wire [2:0]  d_stat_i,
    input  wire [31:0] d_pc_i,
    input  wire [4:0]  d_rs1_i,
    input  wire [4:0]  d_rs2_i,
    input  wire [4:0]  d_rd_i,
    input  wire [4:0]  d_rd_m_i,
    input  wire [31:0] d_rs1_val_i,
    input  wire [31:0] d_rs2_val_i,
    input  wire [31:0] d_imm_i,
    input  wire [3:0]  d_alu_op_i,
    input  wire        d_alu_src_a_i,
    input  wire        d_alu_src_b_i,
    input  wire        d_mem_re_i,
    input  wire        d_mem_we_i,
    input  wire [2:0]  d_mem_width_i,
    input  wire        d_branch_i,
    input  wire        d_jump_i,
    input  wire        d_jalr_i,
    input  wire [31:0] d_valP_i,
    input  wire [2:0]  d_funct3_i,

    output wire [2:0]  E_stat_o,
    output wire [31:0] E_pc_o,
    output wire [4:0]  E_rs1_o,
    output wire [4:0]  E_rs2_o,
    output wire [4:0]  E_rd_o,
    output wire [4:0]  E_rd_m_o,
    output wire [31:0] E_rs1_val_o,
    output wire [31:0] E_rs2_val_o,
    output wire [31:0] E_imm_o,
    output wire [3:0]  E_alu_op_o,
    output wire        E_alu_src_a_o,
    output wire        E_alu_src_b_o,
    output wire        E_mem_re_o,
    output wire        E_mem_we_o,
    output wire [2:0]  E_mem_width_o,
    output wire        E_branch_o,
    output wire        E_jump_o,
    output wire        E_jalr_o,
    output wire [31:0] E_valP_o,
    output wire [2:0]  E_funct3_o
);

    reg [2:0]  E_stat_r;
    reg [31:0] E_pc_r;
    reg [4:0]  E_rs1_r;
    reg [4:0]  E_rs2_r;
    reg [4:0]  E_rd_r;
    reg [4:0]  E_rd_m_r;
    reg [31:0] E_rs1_val_r;
    reg [31:0] E_rs2_val_r;
    reg [31:0] E_imm_r;
    reg [3:0]  E_alu_op_r;
    reg        E_alu_src_a_r;
    reg        E_alu_src_b_r;
    reg        E_mem_re_r;
    reg        E_mem_we_r;
    reg [2:0]  E_mem_width_r;
    reg        E_branch_r;
    reg        E_jump_r;
    reg        E_jalr_r;
    reg [31:0] E_valP_r;
    reg [2:0]  E_funct3_r;

    initial begin
        E_stat_r     = `SAOK;
        E_pc_r       = 32'h0;
        E_rs1_r      = 5'd0;
        E_rs2_r      = 5'd0;
        E_rd_r       = 5'd0;
        E_rd_m_r     = 5'd0;
        E_rs1_val_r  = 32'h0;
        E_rs2_val_r  = 32'h0;
        E_imm_r      = 32'h0;
        E_alu_op_r   = `ALU_ADD;
        E_alu_src_a_r = 1'b0;
        E_alu_src_b_r = 1'b0;
        E_mem_re_r   = 1'b0;
        E_mem_we_r   = 1'b0;
        E_mem_width_r = 3'h0;
        E_branch_r   = 1'b0;
        E_jump_r     = 1'b0;
        E_jalr_r     = 1'b0;
        E_valP_r     = 32'h0;
        E_funct3_r   = 3'h0;
    end

    always @(posedge clk_i) begin
        if (E_bubble_i) begin
            E_stat_r     <= d_stat_i;   // 状态继续传播，不清除
            E_pc_r       <= 32'h0;
            E_rs1_r      <= 5'd0;
            E_rs2_r      <= 5'd0;
            E_rd_r       <= 5'd0;
            E_rd_m_r     <= 5'd0;
            E_rs1_val_r  <= 32'h0;
            E_rs2_val_r  <= 32'h0;
            E_imm_r      <= 32'h0;
            E_alu_op_r   <= `ALU_ADD;
            E_alu_src_a_r <= 1'b0;
            E_alu_src_b_r <= 1'b0;
            E_mem_re_r   <= 1'b0;
            E_mem_we_r   <= 1'b0;
            E_mem_width_r <= 3'h0;
            E_branch_r   <= 1'b0;
            E_jump_r     <= 1'b0;
            E_jalr_r     <= 1'b0;
            E_valP_r     <= 32'h0;
            E_funct3_r   <= 3'h0;
        end
        else if (~E_stall_i) begin
            E_stat_r     <= d_stat_i;
            E_pc_r       <= d_pc_i;
            E_rs1_r      <= d_rs1_i;
            E_rs2_r      <= d_rs2_i;
            E_rd_r       <= d_rd_i;
            E_rd_m_r     <= d_rd_m_i;
            E_rs1_val_r  <= d_rs1_val_i;
            E_rs2_val_r  <= d_rs2_val_i;
            E_imm_r      <= d_imm_i;
            E_alu_op_r   <= d_alu_op_i;
            E_alu_src_a_r <= d_alu_src_a_i;
            E_alu_src_b_r <= d_alu_src_b_i;
            E_mem_re_r   <= d_mem_re_i;
            E_mem_we_r   <= d_mem_we_i;
            E_mem_width_r <= d_mem_width_i;
            E_branch_r   <= d_branch_i;
            E_jump_r     <= d_jump_i;
            E_jalr_r     <= d_jalr_i;
            E_valP_r     <= d_valP_i;
            E_funct3_r   <= d_funct3_i;
        end
    end

    assign E_stat_o      = E_stat_r;
    assign E_pc_o        = E_pc_r;
    assign E_rs1_o       = E_rs1_r;
    assign E_rs2_o       = E_rs2_r;
    assign E_rd_o        = E_rd_r;
    assign E_rd_m_o      = E_rd_m_r;
    assign E_rs1_val_o   = E_rs1_val_r;
    assign E_rs2_val_o   = E_rs2_val_r;
    assign E_imm_o       = E_imm_r;
    assign E_alu_op_o    = E_alu_op_r;
    assign E_alu_src_a_o = E_alu_src_a_r;
    assign E_alu_src_b_o = E_alu_src_b_r;
    assign E_mem_re_o    = E_mem_re_r;
    assign E_mem_we_o    = E_mem_we_r;
    assign E_mem_width_o = E_mem_width_r;
    assign E_branch_o    = E_branch_r;
    assign E_jump_o      = E_jump_r;
    assign E_jalr_o      = E_jalr_r;
    assign E_valP_o      = E_valP_r;
    assign E_funct3_o    = E_funct3_r;

endmodule
