module hazard3_soc_tb;

    reg    clk;

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

    initial begin
		clk <= 0;
        tck <= 0;
        tms <= 0;
        tdi <= 0;
	end
    always #41.66 clk <= (clk === 1'b0);

    fpga_cmodA7 hazard3_soc (
        .clk_osc        (clk),

        .tck            (tck),
        .tms            (tms),
        .tdi            (tdi),
        .tdo            (tdo),

        .uart_tx        (uart_tx),
        .uart_rx        (uart_rx),

        .gpio			(gpio)
    );

endmodule 
`default_nettype wire
