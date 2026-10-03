`timescale 1ns / 1ps

`default_nettype none
`define WT wire


module async_fifo_wrapper#(
      parameter DATAWIDTH = 32
    , parameter DEPTH     = 10
    )(
      input  wire                 w_clk
    , input  wire                 w_rst_n
    , input  wire                 w_wrreq_in
    , input  wire [DATAWIDTH-1:0] w_data_in
    , output wire                 w_full_out

    , input  wire                 r_clk
    , input  wire                 r_rst_n
    , input  wire                 r_rdreq_in
    , output wire [DATAWIDTH-1:0] r_q_out
    , output wire                 r_empty_out
);

/*
fifo1 #(
	  .DSIZE (DATAWIDTH)
	, .ASIZE (ADDRWIDTH)
) fifo1_inst (
	  .rdata  (r_q_out     )
	, .wfull  (w_full_out  )
	, .rempty (r_empty_out )
	, .wdata  (w_data_in   )
	, .winc   (w_wrreq_in  )
	, .wclk   (w_clk       )
	, .wrst_n (w_rst_n     )
	, .rinc   (r_rdreq_in  )
	, .rclk   (r_clk       )
	, .rrst_n (r_rst_n     )
);
*/

async_fifo #(
      .DATAWIDTH (DATAWIDTH    )
    , .DEPTH     (DEPTH        )
) async_fifo_inst (
      .w_clk     (w_clk        )
    , .w_rst_n   (w_rst_n      )
    , .w_wrreq_in(w_wrreq_in   )
    , .w_data_in (w_data_in    )
    , .w_full_out(w_full_out)
    , .r_clk     (r_clk        )
    , .r_rst_n   (r_rst_n      )
    , .r_rdreq_in(r_rdreq_in   )
    , .r_q_out   (r_q_out      )
    , .r_empty_out(r_empty_out )
);

endmodule

`default_nettype wire










