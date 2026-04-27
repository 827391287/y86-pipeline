`include "define.v"

// 数据存储器
// 读：组合逻辑，返回字对齐的 32 位数据
// 写：时序逻辑，按字节使能写入
module dmem(
    input  wire        clk_i,
    input  wire [31:0] addr_i,
    input  wire [31:0] wdata_i,
    input  wire [3:0]  we_i,        // 字节使能：bit0=byte0, bit1=byte1...
    input  wire        re_i,
    output wire [31:0] rdata_o,
    output wire        dmem_error_o
);

    reg [7:0] mem[0:65535];

    initial begin
        $readmemh(`DATA_FILE, mem);
    end

    wire [31:0] waddr = {addr_i[31:2], 2'b00};  // 字对齐

    assign dmem_error_o = (addr_i > 32'd65532);

    assign rdata_o = (re_i && !dmem_error_o) ?
                     {mem[waddr+3], mem[waddr+2], mem[waddr+1], mem[waddr+0]} : 32'h0;

    always @(posedge clk_i) begin
        if (!dmem_error_o) begin
            if (we_i[0]) mem[waddr+0] <= wdata_i[7:0];
            if (we_i[1]) mem[waddr+1] <= wdata_i[15:8];
            if (we_i[2]) mem[waddr+2] <= wdata_i[23:16];
            if (we_i[3]) mem[waddr+3] <= wdata_i[31:24];
        end
    end

endmodule
