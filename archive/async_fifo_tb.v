module async_fifo_tb();

parameter            DATAWIDTH = 8;
parameter            ADDRWIDTH = 3;

reg                  wclk, wrst_n, wpush;
reg                  rclk, rrst_n, rpop;
reg  [DATAWIDTH-1:0] wdin;
wire [DATAWIDTH-1:0] rdout;

async_fifo#(
      .DATAWIDTH (DATAWIDTH)
    , .ADDRWIDTH (ADDRWIDTH)
)dut1(
      .wclk      (wclk     )
    , .wrst_n    (wrst_n   )
    , .wpush     (wpush    )
    , .wdin      (wdin     )
    , .wfull     (wfull    )
    , .rclk      (rclk     )
    , .rrst_n    (rrst_n   )
    , .rpop      (rpop     )
    , .rdout     (rdout    )
    , .rempty    (rempty   )
);



always #5 wclk = ~wclk;
always #3 rclk = ~rclk;

integer ii;
initial begin
    wclk   = 0;
    wrst_n = 0;
    wdin   = 0;
    wpush  = 0;
    rclk   = 0;
    rrst_n = 0;
    rpop   = 0;
    #1007
    wrst_n = 1;
    rrst_n = 1;
    
    #100
    for(ii=0; ii<(1<<ADDRWIDTH); ii = ii+1) begin
        #10
        wpush = 1;
        wdin  = ii+1;
    end
    #10
    wpush = 0;
    
    #100
    for(ii=0; ii<(1<<ADDRWIDTH); ii = ii+1) begin
        #6
        rpop = 1;
    end
    #6
    rpop = 0;
    
    #100
    for(ii=0; ii<(1<<ADDRWIDTH); ii = ii+1) begin
        #10
        wpush = 1;
        wdin  = ii+1;
    end
    #10
    wpush = 0;
    
    #100
    $stop();
end


endmodule
    

    
