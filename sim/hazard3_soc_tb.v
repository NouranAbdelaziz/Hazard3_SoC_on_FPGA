module hazard3_soc_tb;

    reg    clk;
    reg    RSTB;

	reg    tck;
	reg    tms;
	reg    tdi;
	wire   tdo;

	wire   led;

	wire   mirror_tck;
	wire   mirror_tms;
	wire   mirror_tdi;
	wire   mirror_tdo;

	wire   uart_tx;
	reg    uart_rx;

	wire       gpio; 

    wire [3:0]      fdio;
    wire          	fsclk;
    wire          	fcen;

    wire MISO;
    wire MOSI;

    initial begin
		RSTB <= 1'b1;
		
		#4000;
		RSTB <= 1'b0;	    // Release reset
		#2000;
	end

    initial begin
		clk <= 0;
        tck <= 0;
        tms <= 0;
        tdi <= 0;
	end
    always #41.66 clk <= (clk === 1'b0);

   

    fpga_cmodA7 hazard3_soc (
        //.clk_osc_12MHz  (clk),
        .clk_osc  (clk),

        .RSTB           (RSTB),

        .tck            (tck),
        .tms            (tms),
        .tdi            (tdi),
        .tdo            (tdo),

        .uart_tx        (uart_tx),
        .uart_rx        (uart_rx),

        .gpio			(gpio),

        .fsclk          (fsclk),
        .fcen           (fcen),
        //.fdio           (fdio)
        .MISO            (MISO),
        .MOSI             (MOSI)
        
        
    );

    spiflash #(
		.FILENAME("flash_test.mem")
	) spiflash (
		.csb(fcen),
		.clk(fsclk),
		.io0(MOSI),
		.io1(MISO),
		.io2(),			// not used
		.io3()			// not used
	);

    /* initial begin
        #1  $readmemh("flash_test.mem", FLASH.I0.memory);
    end

    sst26wf080b FLASH(
        .SCK(fsclk),
        .SIO({1'b0,1'b0,MISO,MOSI}),
        .CEb(fcen)
    );*/



    

endmodule 
`default_nettype wire