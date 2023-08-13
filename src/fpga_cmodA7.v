/*****************************************************************************\
|                        Copyright (C) 2021 Luke Wren                         |
|                     SPDX-License-Identifier: Apache-2.0                     |
\*****************************************************************************/

// FPGA toplevel for ../soc/example_soc.v on an iCEBreaker dev board

`default_nettype none

module fpga_cmodA7 (
	input wire        clk_osc,

	// No external trst_n as iCEBreaker can't easily drive it from FTDI, so we
	// generate a pulse internally from FPGA PoR.
	input  wire       tck,
	input  wire       tms,
	input  wire       tdi,
	output wire       tdo,

	output wire       led,

	output wire       mirror_tck,
	output wire       mirror_tms,
	output wire       mirror_tdi,
	output wire       mirror_tdo,

	output wire       uart_tx,
	input  wire       uart_rx,

	output wire       gpio 
);

assign mirror_tck = tck;
assign mirror_tms = tms;
assign mirror_tdi = tdi;
assign mirror_tdo = tdo;

wire clk_sys = clk_osc;
wire rst_n_sys;
wire trst_n;

fpga_reset #(
	.SHIFT (3)
) rstgen (
	.clk         (clk_sys),
	.force_rst_n (1'b1),
	.rst_n       (rst_n_sys)
);

reset_sync trst_sync_u (
	.clk       (tck),
	.rst_n_in  (rst_n_sys),
	.rst_n_out (trst_n)
);

activity_led #(
	.WIDTH (1 << 8),
	.ACTIVE_LEVEL (1'b0)
) tck_led_u (
	.clk   (clk_sys),
	.rst_n (rst_n_sys),
	.i     (tck),
	.o     (led)
);

localparam W_ADDR = 32;
localparam W_DATA = 32;

`ifndef CONFIG_HEADER
`define CONFIG_HEADER "config_default.vh"
`endif
`include `CONFIG_HEADER

example_soc #(
	`include "hazard3_config_inst.vh"
) soc_u (
	.clk            (clk_sys),
	.rst_n          (rst_n_sys),

	.tck            (tck),
	.trst_n         (trst_n),
	.tms            (tms),
	.tdi            (tdi),
	.tdo            (tdo),

	.uart_tx        (uart_tx),
	.uart_rx        (uart_rx),

	.gpio			(gpio)
);

endmodule
