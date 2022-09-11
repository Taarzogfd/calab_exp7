module stage_5_WB (
    input  wire clk,
    input  wire reset,

    // valid / allow
    input  wire valid_4,
    output wire allow_5,

    input  wire [69:0] stage_4_to_5,

    output wire rf_we,
    output wire [ 4:0] rf_waddr,    
    output wire [31:0] rf_wdata,
    output wire [31:0] debug_wb_pc
);

reg valid_4_reg;
always @(posedge clk ) begin
    if (reset) valid_4_reg<=1'b1;
    else valid_4_reg<=valid_4;
end

assign allow_5=1'b1;

wire [31:0] pc;
assign debug_wb_pc=pc;

wire [4:0] dest;
wire [31:0] final_result;


reg [69:0] upstream_input;

always @(posedge clk ) begin
    if (reset) upstream_input<=70'b0;
    else if (valid_4 && allow_5) upstream_input<=stage_4_to_5;
end

wire rf_we_internal;
assign {rf_we_internal,dest,final_result,pc}=upstream_input;
assign rf_we=rf_we_internal&valid_4_reg;

assign rf_waddr=dest;
assign rf_wdata=final_result;

endmodule