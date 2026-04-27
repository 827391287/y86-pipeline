// ============================================================
// RV32I 指令集定义
// ============================================================

// ------- 7位操作码 (instr[6:0]) -------
`define OP_R        7'b0110011   // R型：ADD SUB AND OR XOR SLL SRL SRA SLT SLTU
`define OP_I        7'b0010011   // I型：ADDI ANDI ORI XORI SLLI SRLI SRAI SLTI SLTIU
`define OP_LOAD     7'b0000011   // 访存读：LW LH LB LHU LBU
`define OP_STORE    7'b0100011   // 访存写：SW SH SB
`define OP_BRANCH   7'b1100011   // 分支：BEQ BNE BLT BGE BLTU BGEU
`define OP_JAL      7'b1101111   // 无条件跳转并链接
`define OP_JALR     7'b1100111   // 寄存器跳转并链接
`define OP_LUI      7'b0110111   // 加载高位立即数
`define OP_AUIPC    7'b0010111   // PC加高位立即数
`define OP_SYSTEM   7'b1110011   // 系统调用：ECALL EBREAK（用作HALT）

// ------- funct3 (instr[14:12]) -------
// ALU（R型 和 I型共用）
`define F3_ADD      3'b000   // ADD/ADDI，或 SUB（funct7[5]=1时）
`define F3_SLL      3'b001   // SLL/SLLI 逻辑左移寄存器，逻辑左移立即数
`define F3_SLT      3'b010   // SLT/SLTI 有符号比较
`define F3_SLTU     3'b011   // SLTU/SLTIU 无符号比较
`define F3_XOR      3'b100   // XOR/XORI
`define F3_SR       3'b101   // SRL/SRLI 或 SRA/SRAI（funct7[5]=1时）逻辑或算术移位
`define F3_OR       3'b110   // OR/ORI
`define F3_AND      3'b111   // AND/ANDI

// LOAD
`define F3_LB       3'b000
`define F3_LH       3'b001
`define F3_LW       3'b010
`define F3_LBU      3'b100
`define F3_LHU      3'b101

// STORE
`define F3_SB       3'b000
`define F3_SH       3'b001
`define F3_SW       3'b010

// BRANCH
`define F3_BEQ      3'b000
`define F3_BNE      3'b001
`define F3_BLT      3'b100
`define F3_BGE      3'b101
`define F3_BLTU     3'b110
`define F3_BGEU     3'b111

// ------- funct7[5] (instr[30]) -------
// 区分 ADD/SUB，SRL/SRA
`define F7_NORM     1'b0   // 普通：ADD SRL  寄存器操作区分加减指令
`define F7_ALT      1'b1   // 变体：SUB SRA

// ------- 内部ALU操作码（流水线内部使用）-------
`define ALU_ADD     4'h0
`define ALU_SUB     4'h1
`define ALU_AND     4'h2
`define ALU_OR      4'h3
`define ALU_XOR     4'h4
`define ALU_SLL     4'h5
`define ALU_SRL     4'h6
`define ALU_SRA     4'h7
`define ALU_SLT     4'h8
`define ALU_SLTU    4'h9


// ------- 寄存器 ABI 别名（可选，提高可读性）-------
`define ZERO    5'd0    // 恒为0
`define RA      5'd1    // 返回地址
`define SP      5'd2    // 栈指针
`define GP      5'd3    // 全局指针
`define TP      5'd4    // 线程指针
`define T0      5'd5
`define T1      5'd6
`define T2      5'd7
`define S0      5'd8    // 也叫 fp（帧指针）
`define S1      5'd9
`define A0      5'd10   // 函数参数/返回值
`define A1      5'd11
`define A2      5'd12
`define A3      5'd13
`define A4      5'd14
`define A5      5'd15
`define A6      5'd16
`define A7      5'd17
`define S2      5'd18
`define S3      5'd19
`define S4      5'd20
`define S5      5'd21
`define S6      5'd22
`define S7      5'd23
`define S8      5'd24
`define S9      5'd25
`define S10     5'd26
`define S11     5'd27
`define T3      5'd28
`define T4      5'd29
`define T5      5'd30
`define T6      5'd31

// ------- 流水线状态码 -------
`define SAOK    3'h1   // 正常执行
`define SHLT    3'h2   // 程序结束（EBREAK）
`define SADR    3'h3   // 地址错误
`define SINS    3'h4   // 非法指令

// ------- 通用控制 -------
`define ENABLE  1'b1
`define DISABLE 1'b0
