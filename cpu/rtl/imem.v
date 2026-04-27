`include "test_config.v"

// 64KB 指令存储器（字节寻址，按字读取）
// 可替换为 FPGA Block RAM 原语
module imem(
    input  wire [31:0] addr_i,
    output wire [31:0] instr_o,
    output wire        imem_error_o  // 地址超出范围（需4字节对齐读取）
);
    reg [7:0] mem[0:65535];

    initial begin
        $readmemh(`PROG_FILE, mem);
    end

    // 最大合法起始地址：65535 - 3 = 65532
    assign imem_error_o = (addr_i > 32'd65532);

    assign instr_o = imem_error_o ? 32'h0 :
                     {mem[addr_i+3], mem[addr_i+2], mem[addr_i+1], mem[addr_i+0]};

endmodule
