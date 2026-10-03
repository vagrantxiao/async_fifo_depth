
`timescale 1ns / 1ps



`ifdef QUESTA
  `default_nettype none
  `define WT wire
`else
  `define WT
`endif

`ifdef QUESTA
    `define DEBUG 1
`endif



module tb_top;
import afifo_pkg::*;
  localparam int DATAWIDTH   = 8;
  localparam int DEPTH       = 7;
  localparam int NUM_OPS_PER_CLIENT = 32;
  localparam int DRAIN_STEPS  = 64;
  localparam int TOTAL_STEPS  = (4 * NUM_OPS_PER_CLIENT) + DRAIN_STEPS;
  localparam int unsigned TB_SEED = 32'h1ace_b00c;

  // Same-frequency clocks with a phase shift, to observe whether full/empty
  // are ever unnecessarily asserted under full-throughput back-to-back traffic.
  localparam real CLK_PERIOD_NS = 10.0;
  localparam real CLK_HALF_NS   = CLK_PERIOD_NS / 2.0;
  // Phase shift of r_clk relative to w_clk (in ns). Change to explore behavior.
  localparam real R_CLK_PHASE_NS = 2.0;

  afifo_if #(DATAWIDTH) vif();
  afifo_scoreboard      sb;
  afifo_write_monitor   w_mon;
  afifo_read_monitor    r_mon;

  async_fifo_wrapper #(
    .DATAWIDTH   (DATAWIDTH),
    .DEPTH       (DEPTH)
  ) u_dut (
    .w_clk       (vif.w_clk),
    .w_rst_n     (vif.w_rst_n),
    .w_wrreq_in  (vif.w_wrreq_in),
    .w_data_in   (vif.w_data_in),
    .w_full_out  (vif.w_full_out),
    .r_clk       (vif.r_clk),
    .r_rst_n     (vif.r_rst_n),
    .r_rdreq_in  (vif.r_rdreq_in),
    .r_q_out     (vif.r_q_out),
    .r_empty_out (vif.r_empty_out)
  );

  initial begin
    vif.w_clk   = 1'b0;
    vif.r_clk   = 1'b0;
    vif.w_rst_n = 1'b0;
    vif.r_rst_n = 1'b0;
    vif.wrreq_drv = 1'b0;
    vif.rdreq_drv = 1'b0;
    vif.w_data_in  = '0;
  end

  // w_clk starts at time 0, r_clk starts shifted by R_CLK_PHASE_NS
  initial begin
    forever #(CLK_HALF_NS) vif.w_clk = ~vif.w_clk;
  end
  initial begin
    #(R_CLK_PHASE_NS);
    forever #(CLK_HALF_NS) vif.r_clk = ~vif.r_clk;
  end

  initial begin
    repeat (4) @(posedge vif.w_clk);
    vif.w_rst_n <= 1'b1;
    repeat (4) @(posedge vif.r_clk);
    vif.r_rst_n <= 1'b1;
  end

  // Full-throughput write: assert wrreq every w_clk with incrementing data
  initial begin
    byte unsigned d;
    d = '0;
    vif.wrreq_drv = 1'b0;
    vif.w_data_in = '0;
    wait (vif.w_rst_n === 1'b1);
    forever begin
      @(vif.wdrv_cb);
      vif.wdrv_cb.wrreq_drv <= 1'b1;
      vif.wdrv_cb.w_data_in <= d;
      // Only advance the data when the write is actually accepted
      if (!vif.w_full_out) begin
        d = d + 1;
      end
    end
  end

  // Full-throughput read: assert rdreq every r_clk
  initial begin
    vif.rdreq_drv = 1'b0;
    wait (vif.r_rst_n === 1'b1);
    forever begin
      @(vif.rdrv_cb);
      vif.rdrv_cb.rdreq_drv <= 1'b1;
    end
  end


  // Track cycles where full/empty are asserted, to see if they occur
  // "unnecessarily" under matched-frequency, phase-shifted clocks.
  int w_full_cycles;
  int r_empty_cycles;
  int w_accepted;
  int r_accepted;

  always @(posedge vif.w_clk) if (vif.w_rst_n) begin
    if (vif.w_full_out)                 w_full_cycles++;
    if (vif.w_wrreq_in && !vif.w_full_out) w_accepted++;
  end
  always @(posedge vif.r_clk) if (vif.r_rst_n) begin
    if (vif.r_empty_out)                   r_empty_cycles++;
    if (vif.r_rdreq_in && !vif.r_empty_out) r_accepted++;
  end

  initial begin
    int run_cycles;
    bit test_failed;
    sb    = new();
    w_mon = new(vif, sb);
    r_mon = new(vif, sb);
    test_failed = 1'b0;
    run_cycles  = 2000;

    fork
      w_mon.run(run_cycles);
      r_mon.run(run_cycles);
    join

    $display("AFIFO-STATS: w_clk_period=%.2fns r_clk_period=%.2fns r_phase=%.2fns",
             CLK_PERIOD_NS, CLK_PERIOD_NS, R_CLK_PHASE_NS);
    $display("AFIFO-STATS: writes_accepted=%0d w_full_cycles=%0d",
             w_accepted, w_full_cycles);
    $display("AFIFO-STATS: reads_accepted =%0d r_empty_cycles=%0d",
             r_accepted, r_empty_cycles);
    $display("AFIFO-STATS: pending_in_sb  =%0d errors=%0d",
             sb.pending(), sb.errors);

    if (sb.errors != 0) begin
      $error("AFIFO-SB: total mismatches=%0d", sb.errors);
      test_failed = 1'b1;
    end

    if (test_failed) begin
      $fatal(2, "\n\n**********************\n*  AFIFO TEST FAIL   *\n**********************\n\n");
    end

    $display("\n\n**********************\n*  AFIFO TEST PASS   *\n**********************\n\n");
    $finish;
  end

endmodule

`ifdef QUESTA
  `default_nettype wire
`endif
