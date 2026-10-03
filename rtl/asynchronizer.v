`timescale 1ns / 1ps

/*
asynchronizer#(
      .DATAWIDTH(8)
    )(
      .dclk() 
    , .drst_n()
    , .ddout()
    , .sdin()
);
*/

module asynchronizer#(
      parameter DATAWIDTH = 8
    )(
      input  wire                  dclk 
    , input  wire                  drst_n
    , output wire [DATAWIDTH-1:0]  ddout
    , input  wire [DATAWIDTH-1:0]  sdin
);

(* ASYNC_REG = "TRUE" *) reg [DATAWIDTH-1:0] ddin_ff  = {DATAWIDTH{1'b0}};
(* ASYNC_REG = "TRUE" *) reg [DATAWIDTH-1:0] ddout_ff = {DATAWIDTH{1'b0}};

always @(posedge dclk or negedge drst_n) begin
  if (!drst_n) begin
    ddin_ff  <= {DATAWIDTH{1'b0}};
    ddout_ff <= {DATAWIDTH{1'b0}};
  end else begin
    ddin_ff  <= sdin;
    ddout_ff <= ddin_ff;
  end
end

assign ddout = ddout_ff;


endmodule

