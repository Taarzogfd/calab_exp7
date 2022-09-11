module stage_3_EX (
    input  wire clk,
    input  wire reset,

    // valid / allow
    input  wire valid_2,
    output wire allow_3,
    output reg  valid_3,
    input  wire allow_4,

    input  wire [116:0] stage_2_to_3,
    input  wire [31:0]  memory_write_data,
    output wire [31:0] alu_result,
    output wire [31:0] data_sram_wdata,
    output wire [ 3:0] data_sram_we,
    output wire data_sram_en,

    output wire [38:0] stage_3_to_4
);

always @(posedge clk ) begin
    if (reset) valid_3<=1'b1;
    else valid_3<=valid_2;
end

assign allow_3=1'b1;

reg [116:0] upstream_input;
always @(posedge clk ) begin
    if (reset) upstream_input<= 117'd0;
    else if (valid_2 && allow_3) upstream_input <= stage_2_to_3;
end

wire rf_we;
wire res_from_mem;
wire [4:0] dest;
wire [31:0] alu_src1;
wire [31:0] alu_src2;
wire [11:0] alu_op;
wire mem_we;
wire mem_en;
wire [31:0] pc;

assign {rf_we,dest,res_from_mem,alu_src1,alu_src2,alu_op,mem_we,mem_en,pc}=upstream_input;
       // 1 + 5 +   1           + 32      + 32      + 12   +  1  +  1  +32

reg [31:0] memory_write_data_reg;
always @(posedge clk ) begin
    if (reset) memory_write_data_reg<=32'b0;
    else memory_write_data_reg<=memory_write_data;
end
assign data_sram_wdata=memory_write_data_reg;
assign data_sram_we={4{mem_we}};
assign data_sram_en=mem_en;

alu u_alu(
    .alu_op     (alu_op    ),
    .alu_src1   (alu_src1  ),
    .alu_src2   (alu_src2  ),
    .alu_result (alu_result)
    );

assign stage_3_to_4={rf_we,dest,res_from_mem,pc};

endmodule