`include "define.v"

// E 级：纯组合逻辑
// ALU 运算、JALR 目标计算、分支比较
module execute(
    // 主数据输入（来自 decode_E_pipe_reg）
    input  wire [2:0]  stat_i,
    input  wire [31:0] pc_i,
    input  wire [4:0]  rd_i,
    input  wire [4:0]  rd_m_i,
    input  wire [31:0] rs1_val_i,
    input  wire [31:0] rs2_val_i,
    input  wire [31:0] imm_i,
    input  wire [3:0]  alu_op_i,
    input  wire        alu_src_a_i,
    input  wire        alu_src_b_i,
    input  wire        mem_re_i,
    input  wire        mem_we_i,
    input  wire [2:0]  mem_width_i,
    input  wire        branch_i,
    input  wire        jalr_i,
    input  wire [31:0] valP_i,
    input  wire [2:0]  funct3_i,

    // 输出
    output wire [4:0]  rd_o,
    output wire [31:0] rd_val_o,
    output wire [2:0]  stat_o,
    output wire [31:0] pc_o,
    output wire [4:0]  rd_m_o,
    output wire [31:0] rs2_val_o,
    output wire        mem_re_o,
    output wire        mem_we_o,
    output wire [2:0]  mem_width_o,
    output wire        branch_taken_o,
    output wire [31:0] branch_target_o,
    output wire [31:0] jalr_target_o
);

    // ---- ALU 输入选择 ----
    wire [31:0] alu_a = alu_src_a_i ? pc_i  : rs1_val_i;
    wire [31:0] alu_b = alu_src_b_i ? imm_i : rs2_val_i;

    // ---- ALU ----
    reg [31:0] alu_result;
    always @(*) begin
        case (alu_op_i)
            `ALU_ADD:  alu_result = alu_a + alu_b;
            `ALU_SUB:  alu_result = alu_a - alu_b;
            `ALU_AND:  alu_result = alu_a & alu_b;
            `ALU_OR:   alu_result = alu_a | alu_b;
            `ALU_XOR:  alu_result = alu_a ^ alu_b;
            `ALU_SLL:  alu_result = alu_a << alu_b[4:0];
            `ALU_SRL:  alu_result = alu_a >> alu_b[4:0];
            `ALU_SRA:  alu_result = $signed(alu_a) >>> alu_b[4:0];
            `ALU_SLT:  alu_result = ($signed(alu_a) < $signed(alu_b)) ? 32'h1 : 32'h0;
            `ALU_SLTU: alu_result = (alu_a < alu_b) ? 32'h1 : 32'h0;
            default:   alu_result = alu_a + alu_b;
        endcase
    end

    // ---- JALR 目标 & rd 写入值 ----
    assign jalr_target_o = {alu_result[31:1], 1'b0};
    assign rd_val_o      = jalr_i ? valP_i : alu_result;

    // ---- 分支比较 ----
    wire br_eq  = (rs1_val_i == rs2_val_i);
    wire br_lt  = ($signed(rs1_val_i) < $signed(rs2_val_i));
    wire br_ltu = (rs1_val_i < rs2_val_i);

    reg branch_taken;
    always @(*) begin
        case (funct3_i)
            `F3_BEQ:  branch_taken = br_eq;
            `F3_BNE:  branch_taken = ~br_eq;
            `F3_BLT:  branch_taken = br_lt;
            `F3_BGE:  branch_taken = ~br_lt;
            `F3_BLTU: branch_taken = br_ltu;
            `F3_BGEU: branch_taken = ~br_ltu;
            default:  branch_taken = 1'b0;
        endcase
    end

    assign branch_taken_o  = branch_i & branch_taken;
    assign branch_target_o = pc_i + imm_i;

    // ---- 透传 ----
    assign rd_o        = rd_i;
    assign stat_o      = stat_i;
    assign pc_o        = pc_i;
    assign rd_m_o      = rd_m_i;
    assign rs2_val_o   = rs2_val_i;
    assign mem_re_o    = mem_re_i;
    assign mem_we_o    = mem_we_i;
    assign mem_width_o = mem_width_i;

endmodule
