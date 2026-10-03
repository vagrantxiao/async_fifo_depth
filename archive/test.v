module test;

reg         clk;
reg         rst_n;
reg         rinc;
reg         winc;
reg  [31:0] wdata;

wire [31:0] rdata;
wire        rempty;
wire        wfull;


always #5 clk = ~clk;

fifo1 #(
      .DSIZE(32)
	, .ASIZE(10)
	)fifo_inst(
      .rdata  (rdata  )
    , .wfull  (wfull  )
    , .rempty (rempty ) 
    , .wdata  (wdata  )
    , .winc   (winc   )
    , .wclk   (clk    )
    , .wrst_n (rst_n  )
    , .rinc   (rinc   )
    , .rclk   (clk    )
    , .rrst_n (rst_n  )
);

initial begin
	clk = 1;
	rst_n = 0;
	rinc = 0;
	winc = 0;
	wdata = 0;
	#1007;
	rst_n = 1;
	#10
	winc = 1; wdata = 0; #10
	winc = 1; wdata = 1; #10
	winc = 1; wdata = 2; #10
	winc = 1; wdata = 3; #10
	winc = 1; wdata = 4; #10
	winc = 1; wdata = 5; #10
	winc = 1; wdata = 6; #10
	winc = 1; wdata = 7; #10
	winc = 1; wdata = 8; #10
	winc = 0; #1000
	rinc = 1; #1000
	$stop();
end




endmodule
	
