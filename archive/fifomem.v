module fifomem #(
	  parameter DSIZE = 8          // Memory data word width
	, parameter ASIZE = 4          // Number of mem address bits
	, parameter RAM_TYPE = "block" // Type of RAM: string; "auto", "block", or "distributed"
	)(
	  input              wfull
	, input              wclk
	, input              wclken
	, input  [DSIZE-1:0] wdata
	, input  [ASIZE-1:0] waddr
	, input              rclk
	, input  [ASIZE-1:0] raddr
	, output [DSIZE-1:0] rdata
);
	
	
   // xpm_memory_tdpram: True Dual Port RAM
   // Xilinx Parameterized Macro, version 2022.2
   xpm_memory_tdpram #(
    .MEMORY_SIZE        ((1<<ASIZE)*DSIZE    )
  , .MEMORY_PRIMITIVE   ("auto"             )
  , .CLOCKING_MODE      ("independent_clock" )
  , .MEMORY_INIT_FILE   ("none"              )
  , .MEMORY_INIT_PARAM  (""                  )
  , .USE_MEM_INIT       (1                   )
  , .WAKEUP_TIME        ("disable_sleep"     )
  , .MESSAGE_CONTROL    (0                   )
  , .ECC_MODE           ("no_ecc"            )
  , .AUTO_SLEEP_TIME    (0                   )

  // Port A module parameters
  , .WRITE_DATA_WIDTH_A (DSIZE        )
  , .READ_DATA_WIDTH_A  (DSIZE        )
  , .BYTE_WRITE_WIDTH_A (DSIZE        )
  , .ADDR_WIDTH_A       (ASIZE        )
  , .READ_RESET_VALUE_A ("0"          )
  , .READ_LATENCY_A     (0            )
  , .WRITE_MODE_A       ("read_first" )

  // Port B module parameters
  , .WRITE_DATA_WIDTH_B (DSIZE        )
  , .READ_DATA_WIDTH_B  (DSIZE        )
  , .BYTE_WRITE_WIDTH_B (DSIZE        )
  , .ADDR_WIDTH_B       (ASIZE        )
  , .READ_RESET_VALUE_B ("0"          )
  , .READ_LATENCY_B     (1            )
  , .WRITE_MODE_B       ("read_first" )   
  ) xpm_memory_tdpram_inst (
    .clka  (rclk               )
  , .rsta  (1'b0               )
  , .dina  (                   )
  , .douta (rdata              )
  , .addra (raddr              )
  , .ena   (1'b1               )
  , .wea   (1'b0               )
  
  // Port B
  , .clkb  (wclk               )
  , .rstb  (1'b0               )
  , .doutb (                   )
  , .dinb  (wdata              )
  , .addrb (waddr              )
  , .enb   (1'b1               )
  , .web   (wclken && (~wfull) )
  , .sleep (1'b0               )
  );

   // End of xpm_memory_tdpram_inst instantiation

endmodule
