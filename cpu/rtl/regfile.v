// 32 × 32-bit 寄存器堆
// 读口：组合逻辑（由 decode 驱动地址）
// 写口：时序逻辑（由 W 级写回，pipeline_top 连线）
// x0 硬连 0：写入忽略，读取恒返回 0
module regfile(
    input  wire        clk_i,

    // 读口（decode 使用）
    input  wire [4:0]  rs1_addr_i,
    input  wire [4:0]  rs2_addr_i,
    output wire [31:0] rs1_data_o,
    output wire [31:0] rs2_data_o,

    // 写口 1：ALU 结果（R/I/LUI/AUIPC/JAL/JALR）
    input  wire [4:0]  rd_addr_i,
    input  wire [31:0] rd_data_i,

    // 写口 2：LOAD 结果
    input  wire [4:0]  rd_m_addr_i,
    input  wire [31:0] rd_m_data_i
);

    reg [31:0] mem[0:31];

    integer ii;
    initial begin
        for (ii = 0; ii < 32; ii = ii + 1)
            mem[ii] = 32'h0;
    end

    // 同步写回（x0 不写）
    always @(posedge clk_i) begin
        if (rd_addr_i   != 5'd0) mem[rd_addr_i]   <= rd_data_i;
        if (rd_m_addr_i != 5'd0) mem[rd_m_addr_i] <= rd_m_data_i;
    end

    // 组合读（x0 恒为 0）
    assign rs1_data_o = (rs1_addr_i == 5'd0) ? 32'h0 : mem[rs1_addr_i];
    assign rs2_data_o = (rs2_addr_i == 5'd0) ? 32'h0 : mem[rs2_addr_i];

endmodule
