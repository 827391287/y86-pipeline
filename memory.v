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
        mem[0]  = 8'h05; mem[1]  = 8'h00; mem[2]  = 8'h00; mem[3]  = 8'h00;
        mem[4]  = 8'h00; mem[5]  = 8'h00; mem[6]  = 8'h00; mem[7]  = 8'h00;

        mem[8]  = 8'h04; mem[9]  = 8'h00; mem[10] = 8'h00; mem[11] = 8'h00;
        mem[12] = 8'h00; mem[13] = 8'h00; mem[14] = 8'h00; mem[15] = 8'h00;

        mem[16] = 8'h0c; mem[17] = 8'h00; mem[18] = 8'h00; mem[19] = 8'h00;
        mem[20] = 8'h00; mem[21] = 8'h00; mem[22] = 8'h00; mem[23] = 8'h00;

        mem[24] = 8'h02; mem[25] = 8'h00; mem[26] = 8'h00; mem[27] = 8'h00;
        mem[28] = 8'h00; mem[29] = 8'h00; mem[30] = 8'h00; mem[31] = 8'h00;

        mem[32] = 8'h01; mem[33] = 8'h00; mem[34] = 8'h00; mem[35] = 8'h00;
        mem[36] = 8'h00; mem[37] = 8'h00; mem[38] = 8'h00; mem[39] = 8'h00;

        mem[40] = 8'h0b; mem[41] = 8'h00; mem[42] = 8'h00; mem[43] = 8'h00;
        mem[44] = 8'h00; mem[45] = 8'h00; mem[46] = 8'h00; mem[47] = 8'h00;
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
