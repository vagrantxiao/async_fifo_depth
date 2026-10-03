`timescale 1ns / 1ps

interface afifo_if #(parameter int DATAWIDTH = 8);
  logic                 w_clk;
  logic                 w_rst_n;
  logic                 w_wrreq_in;
  logic                 wrreq_drv;
  logic [DATAWIDTH-1:0] w_data_in;
  logic                 w_full_out;

  logic                 r_clk;
  logic                 r_rst_n;
  logic                 r_rdreq_in;
  logic                 rdreq_drv;
  logic [DATAWIDTH-1:0] r_q_out;
  logic                 r_empty_out;

  assign w_wrreq_in = wrreq_drv && !w_full_out;
  assign r_rdreq_in = rdreq_drv && !r_empty_out;

  // Driver clocking blocks: avoid DUT/TB race at posedge
  clocking wdrv_cb @(posedge w_clk);
    default input #1step output #1step;
    input  w_rst_n;
    input  w_full_out;
    output wrreq_drv;
    output w_data_in;
  endclocking

  clocking rdrv_cb @(posedge r_clk);
    default input #1step output #1step;
    input  r_rst_n;
    input  r_empty_out;
    output rdreq_drv;
  endclocking
endinterface
