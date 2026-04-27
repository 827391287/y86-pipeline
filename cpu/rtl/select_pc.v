`include "define.v"

// PC 选择：纯组合逻辑
// 优先级：JALR/分支重定向 > 预测 PC
// JALR 和 branch taken 互斥（E 级不可能同时是两种指令）
module select_pc(
    // 来自 F 级寄存器
    input  wire [31:0] F_predPC_i,

    // 来自 execute 输出
    input  wire        e_branch_taken_i,
    input  wire [31:0] e_branch_target_i,
    input  wire        E_jalr_i,
    input  wire [31:0] e_jalr_target_i,

    output wire [31:0] f_pc_o
);

    assign f_pc_o = E_jalr_i        ? e_jalr_target_i  :
                    e_branch_taken_i ? e_branch_target_i :
                                       F_predPC_i;

endmodule
