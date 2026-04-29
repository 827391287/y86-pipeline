`include "define.v"

module pipeline_top(
    input  wire clk,
    input  wire rst_n,
    output wire halt
);

    // ---- pipeline control ----
    wire F_stall, F_bubble;
    wire D_stall, D_bubble;
    wire E_stall, E_bubble;
    wire M_stall, M_bubble;
    wire W_stall, W_bubble;

    // ---- instruction memory ----
    wire [31:0] imem_addr;
    wire [31:0] imem_data;
    wire        imem_error;

    // ---- F stage ----
    wire [31:0] f_pc;
    wire [31:0] f_instr, f_valP, f_predPC;
    wire [2:0]  f_stat;
    wire [31:0] F_predPC;

    // ---- D stage register outputs ----
    wire [2:0]  D_stat;
    wire [31:0] D_pc, D_instr, D_valP;

    // ---- regfile read data ----
    wire [31:0] rs1_data, rs2_data;

    // ---- decode outputs ----
    wire [4:0]  d_rs1, d_rs2, d_rd, d_rd_m;
    wire [31:0] d_rs1_val, d_rs2_val, d_imm;
    wire [3:0]  d_alu_op;
    wire        d_alu_src_a, d_alu_src_b;
    wire        d_mem_re, d_mem_we;
    wire [2:0]  d_mem_width;
    wire        d_branch, d_jump, d_jalr;
    wire [31:0] d_valP_out;
    wire [2:0]  d_funct3;

    // ---- E stage register outputs ----
    wire [2:0]  E_stat;
    wire [31:0] E_pc;
    wire [4:0]  E_rs1, E_rs2, E_rd, E_rd_m;
    wire [31:0] E_rs1_val, E_rs2_val, E_imm;
    wire [3:0]  E_alu_op;
    wire        E_alu_src_a, E_alu_src_b;
    wire        E_mem_re, E_mem_we;
    wire [2:0]  E_mem_width;
    wire        E_branch, E_jump, E_jalr;
    wire [31:0] E_valP;
    wire [2:0]  E_funct3;

    // ---- execute outputs ----
    wire [4:0]  e_rd, e_rd_m;
    wire [31:0] e_rd_val, e_rs2_val;
    wire [2:0]  e_stat;
    wire [31:0] e_pc;
    wire        e_mem_re, e_mem_we;
    wire [2:0]  e_mem_width;
    wire        e_branch_taken;
    wire [31:0] e_branch_target, e_jalr_target;

    // ---- M stage register outputs ----
    wire [2:0]  M_stat;
    wire [31:0] M_pc;
    wire [4:0]  M_rd, M_rd_m;
    wire [31:0] M_rd_val, M_rs2_val;
    wire        M_mem_re, M_mem_we;
    wire [2:0]  M_mem_width;

    // ---- data memory ----
    wire [31:0] dmem_addr, dmem_wdata;
    wire [3:0]  dmem_we;
    wire        dmem_re;
    wire [31:0] dmem_rdata;
    wire        dmem_error;

    // ---- memory_access outputs ----
    wire [2:0]  m_stat;
    wire [31:0] m_rd_m_val;

    // ---- W stage register outputs ----
    wire [2:0]  W_stat;
    wire [31:0] W_pc;
    wire [4:0]  W_rd, W_rd_m;
    wire [31:0] W_rd_val, W_rd_m_val;

    // ---- writeback outputs ----
    wire [4:0]  w_rd, w_rd_m;
    wire [31:0] w_rd_val, w_rd_m_val;
    wire [2:0]  w_stat;

    assign halt = (W_stat == `SHLT || W_stat == `SADR || W_stat == `SINS);

    // ---- F stage ----
    select_pc select_pc_inst(
        .F_predPC_i        (F_predPC),
        .e_branch_taken_i  (e_branch_taken),
        .e_branch_target_i (e_branch_target),
        .E_jalr_i          (E_jalr),
        .e_jalr_target_i   (e_jalr_target),
        .f_pc_o            (f_pc)
    );

    fetch fetch_inst(
        .PC_i          (f_pc),
        .imem_addr_o   (imem_addr),
        .imem_data_i   (imem_data),
        .imem_error_i  (imem_error),
        .instr_o       (f_instr),
        .valP_o        (f_valP),
        .predPC_o      (f_predPC),
        .stat_o        (f_stat)
    );

    F_pipe_reg F_pipe_reg_inst(
        .clk_i      (clk),
        .F_stall_i  (F_stall),
        .F_bubble_i (F_bubble),
        .f_predPC_i (f_predPC),
        .F_predPC_o (F_predPC)
    );

    imem imem_inst(
        .addr_i       (imem_addr),
        .instr_o      (imem_data),
        .imem_error_o (imem_error)
    );

    // ---- D stage ----
    fetch_D_pipe_reg fetch_D_pipe_reg_inst(
        .clk_i      (clk),
        .D_stall_i  (D_stall),
        .D_bubble_i (D_bubble),
        .f_stat_i   (f_stat),
        .f_pc_i     (f_pc),
        .f_instr_i  (f_instr),
        .f_valP_i   (f_valP),
        .D_stat_o   (D_stat),
        .D_pc_o     (D_pc),
        .D_instr_o  (D_instr),
        .D_valP_o   (D_valP)
    );

    regfile regfile_inst(
        .clk_i       (clk),
        .rs1_addr_i  (d_rs1),
        .rs2_addr_i  (d_rs2),
        .rs1_data_o  (rs1_data),
        .rs2_data_o  (rs2_data),
        .rd_addr_i   (w_rd),
        .rd_data_i   (w_rd_val),
        .rd_m_addr_i (w_rd_m),
        .rd_m_data_i (w_rd_m_val)
    );

    decode decode_inst(
        .instr_i      (D_instr),
        .pc_i         (D_pc),
        .valP_i       (D_valP),
        .rs1_rdata_i  (rs1_data),
        .rs2_rdata_i  (rs2_data),
        .e_rd_i       (E_rd),
        .e_rd_val_i   (e_rd_val),
        .M_rd_i       (M_rd),
        .M_rd_val_i   (M_rd_val),
        .M_rd_m_i     (M_rd_m),
        .m_rd_m_val_i (m_rd_m_val),
        .W_rd_i       (w_rd),
        .W_rd_val_i   (w_rd_val),
        .W_rd_m_i     (w_rd_m),
        .W_rd_m_val_i (w_rd_m_val),
        .rs1_o        (d_rs1),
        .rs2_o        (d_rs2),
        .rd_o         (d_rd),
        .rd_m_o       (d_rd_m),
        .rs1_val_o    (d_rs1_val),
        .rs2_val_o    (d_rs2_val),
        .imm_o        (d_imm),
        .alu_op_o     (d_alu_op),
        .alu_src_a_o  (d_alu_src_a),
        .alu_src_b_o  (d_alu_src_b),
        .mem_re_o     (d_mem_re),
        .mem_we_o     (d_mem_we),
        .mem_width_o  (d_mem_width),
        .branch_o     (d_branch),
        .jump_o       (d_jump),
        .jalr_o       (d_jalr),
        .valP_o       (d_valP_out),
        .funct3_o     (d_funct3)
    );

    // ---- E stage ----
    decode_E_pipe_reg decode_E_pipe_reg_inst(
        .clk_i         (clk),
        .E_stall_i     (E_stall),
        .E_bubble_i    (E_bubble),
        .d_stat_i      (D_stat),
        .d_pc_i        (D_pc),
        .d_rs1_i       (d_rs1),
        .d_rs2_i       (d_rs2),
        .d_rd_i        (d_rd),
        .d_rd_m_i      (d_rd_m),
        .d_rs1_val_i   (d_rs1_val),
        .d_rs2_val_i   (d_rs2_val),
        .d_imm_i       (d_imm),
        .d_alu_op_i    (d_alu_op),
        .d_alu_src_a_i (d_alu_src_a),
        .d_alu_src_b_i (d_alu_src_b),
        .d_mem_re_i    (d_mem_re),
        .d_mem_we_i    (d_mem_we),
        .d_mem_width_i (d_mem_width),
        .d_branch_i    (d_branch),
        .d_jump_i      (d_jump),
        .d_jalr_i      (d_jalr),
        .d_valP_i      (d_valP_out),
        .d_funct3_i    (d_funct3),
        .E_stat_o      (E_stat),
        .E_pc_o        (E_pc),
        .E_rs1_o       (E_rs1),
        .E_rs2_o       (E_rs2),
        .E_rd_o        (E_rd),
        .E_rd_m_o      (E_rd_m),
        .E_rs1_val_o   (E_rs1_val),
        .E_rs2_val_o   (E_rs2_val),
        .E_imm_o       (E_imm),
        .E_alu_op_o    (E_alu_op),
        .E_alu_src_a_o (E_alu_src_a),
        .E_alu_src_b_o (E_alu_src_b),
        .E_mem_re_o    (E_mem_re),
        .E_mem_we_o    (E_mem_we),
        .E_mem_width_o (E_mem_width),
        .E_branch_o    (E_branch),
        .E_jump_o      (E_jump),
        .E_jalr_o      (E_jalr),
        .E_valP_o      (E_valP),
        .E_funct3_o    (E_funct3)
    );

    execute execute_inst(
        .stat_i          (E_stat),
        .pc_i            (E_pc),
        .rd_i            (E_rd),
        .rd_m_i          (E_rd_m),
        .rs1_val_i       (E_rs1_val),
        .rs2_val_i       (E_rs2_val),
        .imm_i           (E_imm),
        .alu_op_i        (E_alu_op),
        .alu_src_a_i     (E_alu_src_a),
        .alu_src_b_i     (E_alu_src_b),
        .mem_re_i        (E_mem_re),
        .mem_we_i        (E_mem_we),
        .mem_width_i     (E_mem_width),
        .branch_i        (E_branch),
        .jalr_i          (E_jalr),
        .valP_i          (E_valP),
        .funct3_i        (E_funct3),
        .rd_o            (e_rd),
        .rd_val_o        (e_rd_val),
        .stat_o          (e_stat),
        .pc_o            (e_pc),
        .rd_m_o          (e_rd_m),
        .rs2_val_o       (e_rs2_val),
        .mem_re_o        (e_mem_re),
        .mem_we_o        (e_mem_we),
        .mem_width_o     (e_mem_width),
        .branch_taken_o  (e_branch_taken),
        .branch_target_o (e_branch_target),
        .jalr_target_o   (e_jalr_target)
    );

    // ---- M stage ----
    execute_M_pipe_reg execute_M_pipe_reg_inst(
        .clk_i         (clk),
        .M_stall_i     (M_stall),
        .M_bubble_i    (M_bubble),
        .e_stat_i      (e_stat),
        .e_pc_i        (e_pc),
        .e_rd_i        (e_rd),
        .e_rd_m_i      (e_rd_m),
        .e_rd_val_i    (e_rd_val),
        .e_rs2_val_i   (e_rs2_val),
        .e_mem_re_i    (e_mem_re),
        .e_mem_we_i    (e_mem_we),
        .e_mem_width_i (e_mem_width),
        .M_stat_o      (M_stat),
        .M_pc_o        (M_pc),
        .M_rd_o        (M_rd),
        .M_rd_m_o      (M_rd_m),
        .M_rd_val_o    (M_rd_val),
        .M_rs2_val_o   (M_rs2_val),
        .M_mem_re_o    (M_mem_re),
        .M_mem_we_o    (M_mem_we),
        .M_mem_width_o (M_mem_width)
    );

    memory_access memory_access_inst(
        .stat_i       (M_stat),
        .rd_val_i     (M_rd_val),
        .rs2_val_i    (M_rs2_val),
        .mem_re_i     (M_mem_re),
        .mem_we_i     (M_mem_we),
        .mem_width_i  (M_mem_width),
        .dmem_addr_o  (dmem_addr),
        .dmem_wdata_o (dmem_wdata),
        .dmem_we_o    (dmem_we),
        .dmem_re_o    (dmem_re),
        .dmem_rdata_i (dmem_rdata),
        .dmem_error_i (dmem_error),
        .stat_o       (m_stat),
        .rd_m_val_o   (m_rd_m_val)
    );

    dmem dmem_inst(
        .clk_i        (clk),
        .addr_i       (dmem_addr),
        .wdata_i      (dmem_wdata),
        .we_i         (dmem_we),
        .re_i         (dmem_re),
        .rdata_o      (dmem_rdata),
        .dmem_error_o (dmem_error)
    );

    // ---- W stage ----
    memory_W_pipe_reg memory_W_pipe_reg_inst(
        .clk_i        (clk),
        .W_stall_i    (W_stall),
        .W_bubble_i   (W_bubble),
        .m_stat_i     (m_stat),
        .m_rd_m_val_i (m_rd_m_val),
        .M_pc_i       (M_pc),
        .M_rd_i       (M_rd),
        .M_rd_val_i   (M_rd_val),
        .M_rd_m_i     (M_rd_m),
        .W_stat_o     (W_stat),
        .W_pc_o       (W_pc),
        .W_rd_o       (W_rd),
        .W_rd_val_o   (W_rd_val),
        .W_rd_m_o     (W_rd_m),
        .W_rd_m_val_o (W_rd_m_val)
    );

    writeback writeback_inst(
        .stat_i      (W_stat),
        .rd_i        (W_rd),
        .rd_val_i    (W_rd_val),
        .rd_m_i      (W_rd_m),
        .rd_m_val_i  (W_rd_m_val),
        .rd_o        (w_rd),
        .rd_val_o    (w_rd_val),
        .rd_m_o      (w_rd_m),
        .rd_m_val_o  (w_rd_m_val),
        .stat_o      (w_stat)
    );

    // ---- controller ----
    controller controller_inst(
        .d_rs1_i         (d_rs1),
        .d_rs2_i         (d_rs2),
        .E_mem_re_i      (E_mem_re),
        .E_rd_m_i        (E_rd_m),
        .E_jalr_i        (E_jalr),
        .e_branch_taken_i(e_branch_taken),
        .m_stat_i        (m_stat),
        .W_stat_i        (W_stat),
        .F_stall_o       (F_stall),
        .F_bubble_o      (F_bubble),
        .D_stall_o       (D_stall),
        .D_bubble_o      (D_bubble),
        .E_stall_o       (E_stall),
        .E_bubble_o      (E_bubble),
        .M_stall_o       (M_stall),
        .M_bubble_o      (M_bubble),
        .W_stall_o       (W_stall),
        .W_bubble_o      (W_bubble)
    );

endmodule
