`include "define.v"

module fetch(
    input  wire [31:0] PC_i,

    // 指令存储器接口（与 imem 或未来的 i_cache 交互）
    output wire [31:0] imem_addr_o,   // 取指地址，直接等于 PC
    input  wire [31:0] imem_data_i,   // 返回的32位指令
    input  wire        imem_error_i,  // 地址越界信号

    output wire [31:0] instr_o,    // 透传指令，供 fetch_D_pipe_reg 使用
    output wire [31:0] valP_o,     // PC+4
    output wire [31:0] predPC_o,   // 预测的下一PC
    output wire [2:0]  stat_o
);

    wire [6:0]  opcode;
    wire [31:0] imm_J;
    wire        instr_valid;

    assign imem_addr_o = PC_i;
    assign instr_o     = imem_data_i;
    assign opcode      = instr_o[6:0];
    assign valP_o      = PC_i + 32'd4;

    assign instr_valid = (opcode == `OP_R)      ||
                         (opcode == `OP_I)      ||
                         (opcode == `OP_LOAD)   ||
                         (opcode == `OP_STORE)  ||
                         (opcode == `OP_BRANCH) ||
                         (opcode == `OP_JAL)    ||
                         (opcode == `OP_JALR)   ||
                         (opcode == `OP_LUI)    ||
                         (opcode == `OP_AUIPC)  ||
                         (opcode == `OP_SYSTEM);

    // J型立即数（用于JAL的静态预测）
    assign imm_J = {{11{instr_o[31]}}, instr_o[31], instr_o[19:12],
                    instr_o[20], instr_o[30:21], 1'b0};

    // 简单分支预测：JAL 直接预测目标，其余预测 PC+4
    assign predPC_o = (opcode == `OP_JAL) ? (PC_i + imm_J) : valP_o;

    // EBREAK（opcode=SYSTEM, instr[20]=1）用作程序结束信号
    assign stat_o = imem_error_i                                   ? `SADR :
                    !instr_valid                                   ? `SINS :
                    (opcode == `OP_SYSTEM && instr_o[20] == 1'b1) ? `SHLT :
                                                                    `SAOK;

endmodule
