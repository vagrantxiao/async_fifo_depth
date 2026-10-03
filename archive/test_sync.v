`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/02/2024 10:18:17 AM
// Design Name: 
// Module Name: test
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module test(

    );
    
reg clk;
reg rst_n;

reg [31:0] din_TDATA;
reg        din_TVALID;
wire       din_TREADY;

wire [31:0] dout_TDATA;
wire        dout_TVALID;
reg         dout_TREADY;
    
sync_fifo i1(
    .clk(clk)
  , .rst_n(rst_n)
  , .din_TDATA(din_TDATA)
  , .din_TVALID(din_TVALID)
  , .din_TREADY(din_TREADY)
  , .dout_TDATA(dout_TDATA)
  , .dout_TVALID(dout_TVALID)
  , .dout_TREADY(dout_TREADY)
);
	
always #5 clk = ~clk;

initial begin
	clk = 0;
	rst_n = 0; #1007
	rst_n = 1; #10
	din_TVALID = 1; din_TDATA = 0; #10
	din_TVALID = 1; din_TDATA = 1; #10
	din_TVALID = 1; din_TDATA = 2; #10
	din_TVALID = 1; din_TDATA = 3; #10
	din_TVALID = 1; din_TDATA = 4; #10
	din_TVALID = 1; din_TDATA = 5; #10
	din_TVALID = 1; din_TDATA = 6; #10
	din_TVALID = 1; din_TDATA = 0; #10
	din_TVALID = 1; din_TDATA = 0; #10
	din_TVALID = 1; din_TDATA = 0; #10
	din_TVALID = 1; din_TDATA = 0; #10
	din_TVALID = 1; din_TDATA = 0; #10
	din_TVALID = 1; din_TDATA = 0; #10
	din_TVALID = 1; din_TDATA = 0; #10
	din_TVALID = 1; din_TDATA = 0; #10
	din_TVALID = 1; din_TDATA = 0; #10
	din_TVALID = 1; din_TDATA = 0; #10
	din_TVALID = 1; din_TDATA = 0; #10
	din_TVALID = 1; din_TDATA = 0; #10
	din_TVALID = 1; din_TDATA = 0; #10
	din_TVALID = 1; din_TDATA = 0; #10
	
	
	
endmodule

