`include "define.v"

// M 级：纯组合逻辑
// 驱动 dmem 接口、对 LOAD 结果做符号/零扩展
module memory_access(
    // 主数据输入（来自 execute_M_pipe_reg）
    input  wire [2:0]  stat_i,
    input  wire [31:0] rd_val_i,    // ALU 结果：访存地址
    input  wire [31:0] rs2_val_i,   // STORE 数据
    input  wire        mem_re_i,
    input  wire        mem_we_i,
    input  wire [2:0]  mem_width_i,

    // dmem 接口
    output wire [31:0] dmem_addr_o,
    output wire [31:0] dmem_wdata_o,
    output wire [3:0]  dmem_we_o,
    output wire        dmem_re_o,
    input  wire [31:0] dmem_rdata_i,
    input  wire        dmem_error_i,

    // 输出
    output wire [2:0]  stat_o,
    output wire [31:0] rd_m_val_o   // LOAD 结果（符号/零扩展后）
);

    wire [1:0] addr_off = rd_val_i[1:0];  // 字内字节偏移

    // ---- STORE 字节使能 ----
    reg [3:0] we;
    always @(*) begin
        if (mem_we_i) begin
            case (mem_width_i)
                `F3_SW: we = 4'b1111;
                `F3_SH: we = addr_off[1] ? 4'b1100 : 4'b0011;
                `F3_SB: we = 4'b0001 << addr_off;
                default: we = 4'b0000;
            endcase
        end else begin
            we = 4'b0000;
        end
    end

    // ---- STORE 写数据对齐（字节使能保证只写对应位置）----
    reg [31:0] wdata;
    always @(*) begin
        case (mem_width_i)
            `F3_SW: wdata = rs2_val_i;
            `F3_SH: wdata = {rs2_val_i[15:0], rs2_val_i[15:0]};
            `F3_SB: wdata = {rs2_val_i[7:0], rs2_val_i[7:0], rs2_val_i[7:0], rs2_val_i[7:0]};
            default: wdata = rs2_val_i;
        endcase
    end

    assign dmem_addr_o  = rd_val_i;
    assign dmem_wdata_o = wdata;
    assign dmem_we_o    = misalign ? 4'b0000 : we;
    assign dmem_re_o    = misalign ? 1'b0    : mem_re_i;

    // ---- LOAD 字节/半字提取 ----
    wire [7:0] load_byte =
        (addr_off == 2'd0) ? dmem_rdata_i[7:0]  :
        (addr_off == 2'd1) ? dmem_rdata_i[15:8] :
        (addr_off == 2'd2) ? dmem_rdata_i[23:16]:
                             dmem_rdata_i[31:24];

    wire [15:0] load_half = addr_off[1] ? dmem_rdata_i[31:16] : dmem_rdata_i[15:0];

    // ---- LOAD 符号/零扩展 ----
    reg [31:0] rd_m_val;
    always @(*) begin
        case (mem_width_i)
            `F3_LB:  rd_m_val = {{24{load_byte[7]}}, load_byte};
            `F3_LH:  rd_m_val = {{16{load_half[15]}}, load_half};
            `F3_LW:  rd_m_val = dmem_rdata_i;
            `F3_LBU: rd_m_val = {24'h0, load_byte};
            `F3_LHU: rd_m_val = {16'h0, load_half};
            default: rd_m_val = dmem_rdata_i;
        endcase
    end

    // ---- 非对齐检测 ----
    wire misalign =
        (mem_re_i && mem_width_i == `F3_LW  && rd_val_i[1:0] != 2'b00) ||
        (mem_re_i && (mem_width_i == `F3_LH  || mem_width_i == `F3_LHU) && rd_val_i[0] != 1'b0) ||
        (mem_we_i && mem_width_i == `F3_SW  && rd_val_i[1:0] != 2'b00) ||
        (mem_we_i && mem_width_i == `F3_SH  && rd_val_i[0]  != 1'b0);

    assign rd_m_val_o = (mem_re_i && !misalign) ? rd_m_val : 32'h0;
    assign stat_o     = (dmem_error_i || misalign) ? `SADR : stat_i;

endmodule
