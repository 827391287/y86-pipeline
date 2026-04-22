`include "define.v"

module pipeline_top(
    input  wire clk,
    input  wire rst_n,
    output wire halt
);

    // ---- pipeline control signals ----
    wire        F_stall, F_bubble;
    wire        D_stall, D_bubble;
    wire        E_stall, E_bubble;
    wire        M_stall, M_bubble;
    wire        W_stall, W_bubble;
    wire        set_cc;

    // ---- F stage ----
    wire [63:0] F_predPC;
    wire [63:0] f_pc;
    wire [3:0]  f_icode, f_ifun, f_rA, f_rB;
    wire [63:0] f_valC, f_valP, f_predPC;
    wire [2:0]  f_stat;

    // ---- D stage registers ----
    wire [63:0] D_pc;
    wire [3:0]  D_icode, D_ifun, D_rA, D_rB;
    wire [63:0] D_valC, D_valP;
    wire [2:0]  D_stat;

    // ---- D stage outputs ----
    wire [63:0] d_valA, d_valB;
    wire [3:0]  d_srcA, d_srcB, d_dstE, d_dstM;

    // ---- E stage registers ----
    wire [63:0] E_pc;
    wire [3:0]  E_icode, E_ifun, E_dstE, E_dstM, E_srcA, E_srcB;
    wire [63:0] E_valC, E_valA, E_valB;
    wire [2:0]  E_stat;

    // ---- E stage outputs ----
    wire [63:0] e_valE;
    wire [3:0]  e_dstE;
    wire        e_Cnd;

    // ---- M stage registers ----
    wire [63:0] M_pc;
    wire [3:0]  M_icode, M_ifun, M_dstE, M_dstM;
    wire [63:0] M_valE, M_valA;
    wire        M_Cnd;
    wire [2:0]  M_stat;

    // ---- M stage outputs ----
    wire [63:0] m_valM;
    wire [2:0]  m_stat;

    // ---- W stage registers ----
    wire [63:0] W_pc;
    wire [3:0]  W_icode, W_dstE, W_dstM;
    wire [63:0] W_valE, W_valM;
    wire [2:0]  W_stat;

    assign halt = (W_stat == `SHLT);

    F_pipe_reg freg(
        .clk_i      (clk),
        .F_stall_i  (F_stall),
        .F_bubble_i (F_bubble),
        .f_predPC_i (f_predPC),
        .F_predPC_o (F_predPC)
    );

    select_pc select_module(
        .F_predPC_i (F_predPC),
        .M_icode_i  (M_icode),
        .W_icode_i  (W_icode),
        .M_valA_i   (M_valA),
        .W_valM_i   (W_valM),
        .M_Cnd_i    (M_Cnd),
        .f_pc_o     (f_pc)
    );

    fetch fetch_module(
        .PC_i      (f_pc),
        .icode_o   (f_icode),
        .ifun_o    (f_ifun),
        .rA_o      (f_rA),
        .rB_o      (f_rB),
        .valC_o    (f_valC),
        .valP_o    (f_valP),
        .predPC_o  (f_predPC),
        .stat_o    (f_stat)
    );

    fetch_D_pipe_reg dreg(
        .clk_i      (clk),
        .D_stall_i  (D_stall),
        .D_bubble_i (D_bubble),
        .f_stat_i   (f_stat),
        .f_pc_i     (f_pc),
        .f_icode_i  (f_icode),
        .f_ifun_i   (f_ifun),
        .f_rA_i     (f_rA),
        .f_rB_i     (f_rB),
        .f_valC_i   (f_valC),
        .f_valP_i   (f_valP),
        .D_stat_o   (D_stat),
        .D_pc_o     (D_pc),
        .D_icode_o  (D_icode),
        .D_ifun_o   (D_ifun),
        .D_rA_o     (D_rA),
        .D_rB_o     (D_rB),
        .D_valC_o   (D_valC),
        .D_valP_o   (D_valP)
    );

    decode decode_module(
        .clk_i     (clk),
        .D_icode_i (D_icode),
        .D_rA_i    (D_rA),
        .D_rB_i    (D_rB),
        .D_valP_i  (D_valP),
        .e_dstE_i  (e_dstE),
        .e_valE_i  (e_valE),
        .M_dstM_i  (M_dstM),
        .m_valM_i  (m_valM),
        .M_dstE_i  (M_dstE),
        .M_valE_i  (M_valE),
        .W_dstM_i  (W_dstM),
        .W_valM_i  (W_valM),
        .W_dstE_i  (W_dstE),
        .W_valE_i  (W_valE),
        .d_valA_o  (d_valA),
        .d_valB_o  (d_valB),
        .d_dstE_o  (d_dstE),
        .d_dstM_o  (d_dstM),
        .d_srcA_o  (d_srcA),
        .d_srcB_o  (d_srcB)
    );

    decode_E_pipe_reg ereg(
        .clk_i      (clk),
        .E_stall_i  (E_stall),
        .E_bubble_i (E_bubble),
        .d_stat_i   (D_stat),
        .d_pc_i     (D_pc),
        .d_icode_i  (D_icode),
        .d_ifun_i   (D_ifun),
        .d_valC_i   (D_valC),
        .d_valA_i   (d_valA),
        .d_valB_i   (d_valB),
        .d_dstE_i   (d_dstE),
        .d_dstM_i   (d_dstM),
        .d_srcA_i   (d_srcA),
        .d_srcB_i   (d_srcB),
        .E_stat_o   (E_stat),
        .E_pc_o     (E_pc),
        .E_icode_o  (E_icode),
        .E_ifun_o   (E_ifun),
        .E_valC_o   (E_valC),
        .E_valA_o   (E_valA),
        .E_valB_o   (E_valB),
        .E_dstE_o   (E_dstE),
        .E_dstM_o   (E_dstM),
        .E_srcA_o   (E_srcA),
        .E_srcB_o   (E_srcB)
    );

    execute execute_module(
        .clk_i    (clk),
        .rst_n_i  (rst_n),
        .E_icode_i(E_icode),
        .E_ifun_i (E_ifun),
        .E_dstE_i (E_dstE),
        .E_valA_i (E_valA),
        .E_valB_i (E_valB),
        .E_valC_i (E_valC),
        .m_stat_i (m_stat),
        .W_stat_i (W_stat),
        .e_valE_o (e_valE),
        .e_dstE_o (e_dstE),
        .e_Cnd_o  (e_Cnd)
    );

    execute_M_pipe_reg mreg(
        .clk_i      (clk),
        .M_stall_i  (M_stall),
        .M_bubble_i (M_bubble),
        .e_stat_i   (E_stat),
        .e_pc_i     (E_pc),
        .e_icode_i  (E_icode),
        .e_ifun_i   (E_ifun),
        .e_Cnd_i    (e_Cnd),
        .e_valE_i   (e_valE),
        .e_valA_i   (E_valA),
        .e_dstE_i   (e_dstE),
        .e_dstM_i   (E_dstM),
        .M_stat_o   (M_stat),
        .M_pc_o     (M_pc),
        .M_icode_o  (M_icode),
        .M_ifun_o   (M_ifun),
        .M_Cnd_o    (M_Cnd),
        .M_valE_o   (M_valE),
        .M_valA_o   (M_valA),
        .M_dstE_o   (M_dstE),
        .M_dstM_o   (M_dstM)
    );

    memory_access memory_module(
        .clk_i    (clk),
        .M_icode_i(M_icode),
        .M_valE_i (M_valE),
        .M_valA_i (M_valA),
        .M_stat_i (M_stat),
        .m_valM_o (m_valM),
        .m_stat_o (m_stat)
    );

    memory_access_W_pipe_reg wreg(
        .clk_i      (clk),
        .W_stall_i  (W_stall),
        .W_bubble_i (W_bubble),
        .m_stat_i   (m_stat),
        .m_pc_i     (M_pc),
        .m_icode_i  (M_icode),
        .M_valE_i   (M_valE),
        .m_valM_i   (m_valM),
        .M_dstE_i   (M_dstE),
        .M_dstM_i   (M_dstM),
        .W_stat_o   (W_stat),
        .W_pc_o     (W_pc),
        .W_icode_o  (W_icode),
        .W_valE_o   (W_valE),
        .W_valM_o   (W_valM),
        .W_dstE_o   (W_dstE),
        .W_dstM_o   (W_dstM)
    );

    controller control(
        .D_icode_i  (D_icode),
        .d_srcA_i   (d_srcA),
        .d_srcB_i   (d_srcB),
        .E_icode_i  (E_icode),
        .E_dstM_i   (E_dstM),
        .e_Cnd_i    (e_Cnd),
        .M_icode_i  (M_icode),
        .m_stat_i   (m_stat),
        .W_stat_i   (W_stat),
        .F_stall_o  (F_stall),
        .F_bubble_o (F_bubble),
        .D_bubble_o (D_bubble),
        .D_stall_o  (D_stall),
        .E_stall_o  (E_stall),
        .E_bubble_o (E_bubble),
        .set_cc_o   (set_cc),
        .M_stall_o  (M_stall),
        .M_bubble_o (M_bubble),
        .W_stall_o  (W_stall),
        .W_bubble_o (W_bubble)
    );

endmodule
