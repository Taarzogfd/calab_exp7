module stage_4_AM (
    input  wire clk,
    input  wire reset,

    // valid / allow
    input  wire valid_3,
    output wire allow_4,
    output reg  valid_4,
    input  wire allow_5,

    input wire [38:0]  stage_3_to_4,
    input wire [31:0] alu_result,
    input wire [31:0] data_sram_rdata,
    output wire [69:0] stage_4_to_5
);

wire [31:0] pc;

always @(posedge clk ) begin
    if (reset) valid_4<=1'b1;
    else valid_4<=valid_3;
end

assign allow_4=1'b1;

wire res_from_mem;

wire rf_we;
wire [4:0] dest;

wire [31:0] mem_result;
wire [31:0] final_result;


reg [31:0] alu_result_reg;
reg [38:0] upstream_input;

always @(posedge clk ) begin
    if (reset) alu_result_reg<=39'b0;
    else if (valid_3 && allow_4) alu_result_reg<=alu_result;
end

always @(posedge clk ) begin
    if (reset) upstream_input<=39'b0;
    else if (valid_3 && allow_4) upstream_input<=stage_3_to_4;
end


assign mem_result   = data_sram_rdata;
assign final_result = res_from_mem ? mem_result : alu_result_reg;

assign {rf_we,dest,res_from_mem,pc}=upstream_input;
assign stage_4_to_5={rf_we,dest,final_result,pc};

endmodule

