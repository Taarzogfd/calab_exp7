module stage_1_IF(
    input wire clk,
    input wire reset,

    // valid / allow
    output wire valid_1,
    input  wire allow_2,
    
    input  wire        br_taken,
    input  wire [31:0] br_target,

    output wire [63:0]  stage_1_to_2,
    // output wire sram
    output wire        inst_sram_en,
    output wire [ 3:0] inst_sram_we,
    output wire [31:0] inst_sram_addr,
    output wire [31:0] inst_sram_wdata,
    input  wire [31:0] inst_sram_rdata
);

assign valid_1 = ~reset;

wire [31:0] ds_pc;
wire [31:0] seq_pc;
wire [31:0] nextpc;
wire [31:0] inst;
reg  [31:0] pc;

// PC
assign ds_pc        = pc;
assign seq_pc       = ds_pc + 3'h4;
assign nextpc       = br_taken ? br_target : seq_pc;

always @(posedge clk) begin
    if (reset) begin
        pc <= 32'h1c000000; 
        //pc <= 32'h1bff_fffc;
    end
    else begin
        pc <= nextpc;
    end
end

assign inst_sram_we    = 1'b0;
assign inst_sram_en    = 1'b1;
assign inst_sram_addr  = nextpc; //pc; changed for pipeline
assign inst_sram_wdata = 32'b0;
assign inst            = inst_sram_rdata;

assign stage_1_to_2 = {inst,pc};

endmodule