`include "define.v"

// 流水线控制器：纯组合逻辑
// 检测 load-use 冒险、分支/JALR 冲刷、异常传播
// 输出各级 stall/bubble 信号
module controller(
    // 来自 D 级（decode 输出）
    input  wire [4:0]  d_rs1_i,
    input  wire [4:0]  d_rs2_i,

    // 来自 E 级寄存器
    input  wire        E_mem_re_i,     // E 级是 LOAD
    input  wire [4:0]  E_rd_m_i,       // LOAD 目标寄存器
    input  wire        E_jalr_i,       // E 级是 JALR

    // 来自 execute 输出
    input  wire        e_branch_taken_i,

    // 来自 memory_access 输出
    input  wire [2:0]  m_stat_i,

    // 来自 W 级寄存器
    input  wire [2:0]  W_stat_i,

    output wire        F_stall_o,
    output wire        F_bubble_o,
    output wire        D_stall_o,
    output wire        D_bubble_o,
    output wire        E_stall_o,
    output wire        E_bubble_o,
    output wire        M_stall_o,
    output wire        M_bubble_o,
    output wire        W_stall_o,
    output wire        W_bubble_o
);

    // ---- load-use 冒险检测 ----
    // E 级是 LOAD 且 D 级指令依赖该结果 → stall 1 周期
    wire load_use = E_mem_re_i &&
                   (E_rd_m_i != 5'd0) &&
                   (E_rd_m_i == d_rs1_i || E_rd_m_i == d_rs2_i);

    // ---- 控制流重定向 ----
    // JALR：目标在 E 级才能算出，D 级已取入错误指令
    // BRANCH taken：E 级判定跳转成立，D 级已取入错误指令
    wire redirect = E_jalr_i || e_branch_taken_i;

    // ---- 异常传播 ----
    wire exception = (m_stat_i == `SADR || m_stat_i == `SINS) ||
                     (W_stat_i == `SADR || W_stat_i == `SINS || W_stat_i == `SHLT);

    // ---- stall / bubble 生成 ----
    // F：load-use 时暂停，重复取同一条指令
    assign F_stall_o  = load_use;
    assign F_bubble_o = 1'b0;

    // D：load-use 时暂停；redirect 时清除（两者互斥，E 不可能同时是 LOAD 和 BRANCH/JALR）
    assign D_stall_o  = load_use;
    assign D_bubble_o = 1'b0;

    // E：load-use 插 NOP 防止依赖指令进入 E；redirect 防止 D 级错误指令进入 E
    assign E_stall_o  = 1'b0;
    assign E_bubble_o = load_use || redirect;

    // M：异常时插入 bubble，防止错误指令产生副作用
    assign M_stall_o  = 1'b0;
    assign M_bubble_o = exception;

    // W：错误到达 W 级时暂停，保持错误状态供 pipeline_top 检测 halt
    assign W_stall_o  = (W_stat_i == `SADR || W_stat_i == `SINS || W_stat_i == `SHLT);
    assign W_bubble_o = 1'b0;

endmodule
