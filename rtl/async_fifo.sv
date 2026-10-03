`timescale 1ns / 1ps

`default_nettype none
`define WT wire


module async_fifo#(
      parameter DATAWIDTH = 8
    , parameter DEPTH     = 4
    )(
      input  wire                 w_clk
    , input  wire                 w_rst_n
    , input  wire                 w_wrreq_in
    , input  wire [DATAWIDTH-1:0] w_data_in
    , output logic                w_full_out

    , input  wire                 r_clk
    , input  wire                 r_rst_n
    , input  wire                 r_rdreq_in
    , output wire [DATAWIDTH-1:0] r_q_out
    , output wire                 r_empty_out
);


initial begin
  if (DATAWIDTH <= 0) begin
    $fatal(1, "DATAWIDTH must be > 0, got %0d", DATAWIDTH);
  end
  if (DEPTH < 2) begin
    $fatal(1, "ADDRWIDTH must be >= 2, got %0d", DEPTH);
  end
end

localparam ADDRWIDTH = $clog2(DEPTH);


// local block ram
logic [DATAWIDTH-1 : 0] mem [0 : DEPTH - 1];

typedef struct packed {
  logic [ADDRWIDTH : 0] bin_ptr;
  logic                 full;
} w_state_t;

w_state_t w_st_nxt, w_st_ff;

logic [ADDRWIDTH : 0] wr_bin_ptr_net;

typedef struct packed {
  logic [ADDRWIDTH : 0] bin_ptr;
  logic                 empty;
} r_state_t;

r_state_t r_st_nxt, r_st_ff;

logic [ADDRWIDTH : 0] rw_bin_ptr_net;

//==========================================
//          Write logic
//==========================================

asynchronizer
#(
      .DATAWIDTH(ADDRWIDTH + 1)
) r2w_bin_ptr (
      .dclk   (w_clk) 
    , .drst_n (w_rst_n)
    , .ddout  (wr_bin_ptr_net )
    , .sdin   (r_st_ff.bin_ptr)
);

always_comb begin
  // assign values to avoid latches
  w_st_nxt        = w_st_ff;

  // logic calculation
  if (w_wrreq_in && !w_st_ff.full) begin
    if (w_st_nxt.bin_ptr[ADDRWIDTH-1:0] == DEPTH-1) begin
      w_st_nxt.bin_ptr = {~w_st_ff.bin_ptr[ADDRWIDTH], {ADDRWIDTH{1'b0}}};
    end else begin
      w_st_nxt.bin_ptr = w_st_ff.bin_ptr + 1;
    end
  end

  // Full: MSBs differ AND lower address bits equal (binary pointer form)
  if (w_st_nxt.bin_ptr == {~wr_bin_ptr_net[ADDRWIDTH], wr_bin_ptr_net[ADDRWIDTH-1:0]}) begin
    w_st_nxt.full = 1'b1;
  end else begin
    w_st_nxt.full = 1'b0;
  end
end

always_ff @(posedge w_clk or negedge w_rst_n) begin
  if (!w_rst_n) begin
    w_st_ff.bin_ptr <= '0;
    w_st_ff.full    <= 1'b0;
  end else begin
    w_st_ff         <= w_st_nxt;
  end
end

always_ff @(posedge w_clk) begin
  if (w_wrreq_in && !w_st_ff.full) begin
    mem[w_st_ff.bin_ptr[ADDRWIDTH-1:0]] <= w_data_in;
  end
end

assign w_full_out = w_st_ff.full;

//==========================================
//          read logic
//==========================================

asynchronizer
#(
     .DATAWIDTH(ADDRWIDTH + 1 )
) w2r_bin_ptr (
      .dclk   (r_clk) 
    , .drst_n (r_rst_n)
    , .ddout  (rw_bin_ptr_net )
    , .sdin   (w_st_ff.bin_ptr)
);

always_comb begin
  // assign values to avoid latches
  r_st_nxt = r_st_ff;

  // logic calculation
  if (r_rdreq_in && !r_st_ff.empty) begin
    if (r_st_ff.bin_ptr[ADDRWIDTH-1:0] == DEPTH - 1) begin
      r_st_nxt.bin_ptr = {~r_st_ff.bin_ptr[ADDRWIDTH], {ADDRWIDTH{1'b0}}};
    end else begin
      r_st_nxt.bin_ptr = r_st_ff.bin_ptr + 1;
    end
  end

  if (r_st_nxt.bin_ptr == rw_bin_ptr_net)begin
    r_st_nxt.empty = 1'b1;
  end else begin
    r_st_nxt.empty = 1'b0;
  end

end


always_ff @(posedge r_clk or negedge r_rst_n) begin
  if (!r_rst_n) begin
    r_st_ff.bin_ptr <= '0;
    r_st_ff.empty   <= 1'b1;
  end else begin
    r_st_ff     <= r_st_nxt;
  end
end


// Mimic the look ahead feature of FIFO
assign r_q_out     = mem[r_st_ff.bin_ptr[ADDRWIDTH-1:0]];
assign r_empty_out = r_st_ff.empty;

endmodule

`default_nettype wire










