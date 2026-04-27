`include "define.v"

// D 级：纯组合逻辑，指令解码 + 数据前递
// 寄存器堆已独立为 regfile.v，本模块只做解码和前递选择
module decode(
    // 主数据输入（来自 F→D 流水线寄存器）
    input  wire [31:0] instr_i,
    input  wire [31:0] pc_i,
    input  wire [31:0] valP_i,      // PC+4，用于 JAL/JALR 链接值

    // 寄存器堆读出值（来自 regfile，经前递网络后输出）
    input  wire [31:0] rs1_rdata_i,
    input  wire [31:0] rs2_rdata_i,

    // 前递输入：各级写回目标寄存器号和数据
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

    // 寄存器编号（供 regfile 寻址 + 控制器冒险检测）
    output wire [4:0]  rs1_o,
    output wire [4:0]  rs2_o,
    output wire [4:0]  rd_o,        // ALU 结果写回目标（x0 = 不写）
    output wire [4:0]  rd_m_o,      // LOAD 结果写回目标（x0 = 不写）

    // 前递后的寄存器值
    output wire [31:0] rs1_val_o,
    output wire [31:0] rs2_val_o,

    // 立即数
    output wire [31:0] imm_o,

    // ALU 控制
    output wire [3:0]  alu_op_o,
    output wire        alu_src_a_o, // 0=rs1_val, 1=PC（仅 AUIPC）
    output wire        alu_src_b_o, // 0=rs2_val, 1=imm

    // 访存控制
    output wire        mem_re_o,
    output wire        mem_we_o,
    output wire [2:0]  mem_width_o,

    // 分支/跳转控制
    output wire        branch_o,
    output wire        jump_o,
    output wire        jalr_o,

    // 透传
    output wire [31:0] valP_o,
    output wire [2:0]  funct3_o
);

    // ---- 指令字段提取 ----
    wire [6:0] opcode   = instr_i[6:0];
    wire [4:0] rd       = instr_i[11:7];
    wire [2:0] funct3   = instr_i[14:12];
    wire [4:0] rs1      = instr_i[19:15];
    wire [4:0] rs2      = instr_i[24:20];
    wire       funct7_5 = instr_i[30];

    // ---- 源/目标寄存器号 ----
    assign rs1_o  = (opcode == `OP_JAL   ||
                     opcode == `OP_LUI   ||
                     opcode == `OP_AUIPC) ? 5'd0 : rs1;
    assign rs2_o  = (opcode == `OP_R     ||
                     opcode == `OP_STORE  ||
                     opcode == `OP_BRANCH) ? rs2 : 5'd0;
    assign rd_o   = (opcode == `OP_R    ||
                     opcode == `OP_I    ||
                     opcode == `OP_JAL  ||
                     opcode == `OP_JALR ||
                     opcode == `OP_LUI  ||
                     opcode == `OP_AUIPC) ? rd : 5'd0;
    assign rd_m_o = (opcode == `OP_LOAD) ? rd : 5'd0;

    // ---- 立即数生成 ----
    wire [31:0] imm_I = {{20{instr_i[31]}}, instr_i[31:20]};
    wire [31:0] imm_S = {{20{instr_i[31]}}, instr_i[31:25], instr_i[11:7]};
    wire [31:0] imm_B = {{19{instr_i[31]}}, instr_i[31],    instr_i[7],
                          instr_i[30:25],   instr_i[11:8],  1'b0};
    wire [31:0] imm_U = {instr_i[31:12], 12'h0};
    wire [31:0] imm_J = {{11{instr_i[31]}}, instr_i[31],    instr_i[19:12],
                          instr_i[20],       instr_i[30:21], 1'b0};

    assign imm_o = (opcode == `OP_STORE)                      ? imm_S :
                   (opcode == `OP_BRANCH)                     ? imm_B :
                   (opcode == `OP_LUI || opcode == `OP_AUIPC) ? imm_U :
                   (opcode == `OP_JAL)                        ? imm_J :
                                                                imm_I;

    // ---- ALU 操作码译码 ----
    reg [3:0] alu_op;
    always @(*) begin
        case (opcode)
            `OP_LUI:    alu_op = `ALU_ADD;
            `OP_AUIPC:  alu_op = `ALU_ADD;
            `OP_JAL:    alu_op = `ALU_ADD;
            `OP_JALR:   alu_op = `ALU_ADD;
            `OP_LOAD:   alu_op = `ALU_ADD;
            `OP_STORE:  alu_op = `ALU_ADD;
            `OP_BRANCH: alu_op = `ALU_ADD;
            `OP_I: begin
                case (funct3)
                    `F3_ADD:  alu_op = `ALU_ADD;
                    `F3_SLL:  alu_op = `ALU_SLL;
                    `F3_SLT:  alu_op = `ALU_SLT;
                    `F3_SLTU: alu_op = `ALU_SLTU;
                    `F3_XOR:  alu_op = `ALU_XOR;
                    `F3_SR:   alu_op = funct7_5 ? `ALU_SRA : `ALU_SRL;
                    `F3_OR:   alu_op = `ALU_OR;
                    `F3_AND:  alu_op = `ALU_AND;
                    default:  alu_op = `ALU_ADD;
                endcase
            end
            `OP_R: begin
                case (funct3)
                    `F3_ADD:  alu_op = funct7_5 ? `ALU_SUB : `ALU_ADD;
                    `F3_SLL:  alu_op = `ALU_SLL;
                    `F3_SLT:  alu_op = `ALU_SLT;
                    `F3_SLTU: alu_op = `ALU_SLTU;
                    `F3_XOR:  alu_op = `ALU_XOR;
                    `F3_SR:   alu_op = funct7_5 ? `ALU_SRA : `ALU_SRL;
                    `F3_OR:   alu_op = `ALU_OR;
                    `F3_AND:  alu_op = `ALU_AND;
                    default:  alu_op = `ALU_ADD;
                endcase
            end
            default: alu_op = `ALU_ADD;
        endcase
    end
    assign alu_op_o = alu_op;

    assign alu_src_a_o = (opcode == `OP_AUIPC) ? 1'b1 : 1'b0;
    assign alu_src_b_o = (opcode == `OP_R || opcode == `OP_BRANCH || opcode == `OP_JAL) ? 1'b0 : 1'b1;

    assign mem_re_o    = (opcode == `OP_LOAD);
    assign mem_we_o    = (opcode == `OP_STORE);
    assign mem_width_o = funct3;

    assign branch_o = (opcode == `OP_BRANCH);
    assign jump_o   = (opcode == `OP_JAL || opcode == `OP_JALR);
    assign jalr_o   = (opcode == `OP_JALR);

    assign valP_o   = valP_i;
    assign funct3_o = funct3;

    // ---- 前递网络 ----
    sel_fwd fwdA(
        .opcode_i     (opcode),
        .valP_i       (valP_i),
        .rs1_i        (rs1_o),
        .e_rd_i       (e_rd_i),     .e_rd_val_i    (e_rd_val_i),
        .M_rd_i       (M_rd_i),     .M_rd_val_i    (M_rd_val_i),
        .M_rd_m_i     (M_rd_m_i),   .m_rd_m_val_i  (m_rd_m_val_i),
        .W_rd_i       (W_rd_i),     .W_rd_val_i    (W_rd_val_i),
        .W_rd_m_i     (W_rd_m_i),   .W_rd_m_val_i  (W_rd_m_val_i),
        .rvalA_i      (rs1_rdata_i),
        .rs1_val_o    (rs1_val_o)
    );

    fwd fwdB(
        .rs2_i        (rs2_o),
        .e_rd_i       (e_rd_i),     .e_rd_val_i    (e_rd_val_i),
        .M_rd_i       (M_rd_i),     .M_rd_val_i    (M_rd_val_i),
        .M_rd_m_i     (M_rd_m_i),   .m_rd_m_val_i  (m_rd_m_val_i),
        .W_rd_i       (W_rd_i),     .W_rd_val_i    (W_rd_val_i),
        .W_rd_m_i     (W_rd_m_i),   .W_rd_m_val_i  (W_rd_m_val_i),
        .rvalB_i      (rs2_rdata_i),
        .rs2_val_o    (rs2_val_o)
    );

endmodule
