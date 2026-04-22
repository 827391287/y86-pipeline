`include "define.v"

module ram(
    input  wire        clk_i,
    input  wire        r_en,
    input  wire        w_en,
    input  wire [63:0] addr_i,
    input  wire [63:0] wdata_i,
    output wire [63:0] rdata_o,
    output wire        dmem_error_o
);

    reg [7:0] mem[1023:0];

    assign dmem_error_o = (addr_i > 1023) ? 1'b1 : 1'b0;

    assign rdata_o = (r_en == 1'b1) ?
        {mem[addr_i+7], mem[addr_i+6], mem[addr_i+5], mem[addr_i+4],
         mem[addr_i+3], mem[addr_i+2], mem[addr_i+1], mem[addr_i+0]} : 64'b0;

    always @(posedge clk_i) begin
        if (w_en)
            {mem[addr_i+7], mem[addr_i+6], mem[addr_i+5], mem[addr_i+4],
             mem[addr_i+3], mem[addr_i+2], mem[addr_i+1], mem[addr_i+0]} <= wdata_i;
    end

    initial begin
        $readmemh("data.mem", mem);
    end

endmodule


module memory_access(
    input  wire        clk_i,
    input  wire [3:0]  M_icode_i,
    input  wire [63:0] M_valE_i,
    input  wire [63:0] M_valA_i,
    input  wire [2:0]  M_stat_i,
    output wire [63:0] m_valM_o,
    output wire [2:0]  m_stat_o
);

    reg        r_en;
    reg        w_en;
    wire       dmem_error;
    reg [63:0] mem_addr;

    always @(*) begin
        case (M_icode_i)
            `IRMMOVQ: begin
                r_en     = 1'b0;
                w_en     = 1'b1;
                mem_addr = M_valE_i;
            end
            `IMRMOVQ: begin
                r_en     = 1'b1;
                w_en     = 1'b0;
                mem_addr = M_valE_i;
            end
            `ICALL: begin
                r_en     = 1'b0;
                w_en     = 1'b1;
                mem_addr = M_valE_i;
            end
            `IRET: begin
                r_en     = 1'b1;
                w_en     = 1'b0;
                mem_addr = M_valA_i;
            end
            `IPUSHQ: begin
                r_en     = 1'b0;
                w_en     = 1'b1;
                mem_addr = M_valE_i;
            end
            `IPOPQ: begin
                r_en     = 1'b1;
                w_en     = 1'b0;
                mem_addr = M_valA_i;
            end
            default: begin
                r_en     = 1'b0;
                w_en     = 1'b0;
                mem_addr = 64'b0;
            end
        endcase
    end

    assign m_stat_o = dmem_error ? `SADR : M_stat_i;

    ram ram_module(
        .clk_i       (clk_i),
        .r_en        (r_en),
        .w_en        (w_en),
        .addr_i      (mem_addr),
        .wdata_i     (M_valA_i),
        .rdata_o     (m_valM_o),
        .dmem_error_o(dmem_error)
    );

endmodule
