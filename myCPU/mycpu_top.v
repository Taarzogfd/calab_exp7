module mycpu_top(
    input  wire        clk,
    input  wire        resetn,
    // inst sram interface
    output wire        inst_sram_en,
    output wire [ 3:0] inst_sram_we,
    output wire [31:0] inst_sram_addr,
    output wire [31:0] inst_sram_wdata,
    input  wire [31:0] inst_sram_rdata,
    // data sram interface
    output wire        data_sram_en,
    output wire [ 3:0] data_sram_we,
    output wire [31:0] data_sram_addr,
    output wire [31:0] data_sram_wdata,
    input  wire [31:0] data_sram_rdata,
    // trace debug interface
    output wire [31:0] debug_wb_pc,
    output wire [ 3:0] debug_wb_rf_we,
    output wire [ 4:0] debug_wb_rf_wnum,
    output wire [31:0] debug_wb_rf_wdata
);

wire reset;
assign reset = ~resetn;
// VALID & ALLOW GENERATION
wire valid_1; // the valid signal given by stage 1
wire valid_2; // beq bne b 执行到此为止
wire valid_3; 
wire valid_4;
//wire valid_5;

//wire allow_1;
wire allow_2; // branch 类 指令需要阻塞
wire allow_3;
wire allow_4;
wire allow_5;

wire        br_taken;
wire [31:0] br_target;

wire [ 4:0] rf_waddr;
wire [31:0] rf_wdata;

wire rf_we;

wire [63:0]  stage_1_to_2;
stage_1_IF instantiation_IF  (
    .clk (clk),
    .valid_1 (valid_1),
    .allow_2 (allow_2),
    .reset (reset),
    .br_taken (br_taken),
    .br_target (br_target),
    .stage_1_to_2 (stage_1_to_2),
    .inst_sram_en (inst_sram_en),
    .inst_sram_we (inst_sram_we),
    .inst_sram_addr (inst_sram_addr),
    .inst_sram_wdata (inst_sram_wdata),
    .inst_sram_rdata (inst_sram_rdata)
);


wire [31:0] rf_rdata1;
wire [31:0] rf_rdata2;
wire [ 4:0] rf_raddr1;
wire [ 4:0] rf_raddr2;

wire [116:0] stage_2_to_3;
wire [31:0]  memory_write_data;
stage_2_ID instantiation_ID  (
    .clk (clk),
    .reset (reset),
    .valid_1 (valid_1),
    .valid_2 (valid_2),
    .allow_2 (allow_2),
    .allow_3 (allow_3),
    .stage_1_to_2 (stage_1_to_2),
    .br_taken (br_taken),
    .br_target (br_target),
    .stage_2_to_3 (stage_2_to_3),
    .memory_write_data (memory_write_data),
    .rf_raddr1 (rf_raddr1),
    .rf_raddr2 (rf_raddr2),
    .rf_rdata1 (rf_rdata1),
    .rf_rdata2 (rf_rdata2)
);

wire [38:0] stage_3_to_4;
wire [31:0] alu_result;

 stage_3_EX instantiation_EX(
    .clk (clk),
    .reset (reset),
    .valid_2 (valid_2),
    .valid_3 (valid_3),
    .allow_3 (allow_3),
    .allow_4 (allow_4),
    .stage_2_to_3 (stage_2_to_3),
    .memory_write_data (memory_write_data),
    .alu_result (alu_result),
    .data_sram_wdata (data_sram_wdata),
    .data_sram_we (data_sram_we),
    .data_sram_en (data_sram_en),
    .stage_3_to_4 (stage_3_to_4)
);

assign data_sram_addr=alu_result;

wire [69:0] stage_4_to_5;
 stage_4_AM instantiation_AM(
    .clk (clk),
    .reset (reset),
    .valid_3 (valid_3),
    .valid_4 (valid_4),
    .allow_4 (allow_4),
    .allow_5 (allow_5),
    .stage_3_to_4 (stage_3_to_4),
    .alu_result (alu_result),
    .data_sram_rdata (data_sram_rdata),
    .stage_4_to_5 (stage_4_to_5)
);

 stage_5_WB instantiation_WB(
    .clk (clk),
    .reset (reset),
    .valid_4 (valid_4),
    .allow_5 (allow_5),
    .stage_4_to_5 (stage_4_to_5),
    .rf_we (rf_we),
    .rf_waddr (rf_waddr),
    .rf_wdata (rf_wdata),
    .debug_wb_pc (debug_wb_pc)
);

regfile u_regfile(
    .clk    (clk      ),
    .raddr1 (rf_raddr1),
    .rdata1 (rf_rdata1),
    .raddr2 (rf_raddr2),
    .rdata2 (rf_rdata2),
    .we     (rf_we    ),
    .waddr  (rf_waddr ),
    .wdata  (rf_wdata )
    );

assign debug_wb_rf_we   = {4{rf_we}};
assign debug_wb_rf_wnum  = rf_waddr;
assign debug_wb_rf_wdata = rf_wdata;

endmodule