`define RAM
// Hex files
`define ROM_HEX_INTEL   "../mem/test_rom_i.mem"
`define ROM_HEX_VERILOG "../mem/test_rom_v.mem"
`define RAM_HEX_INTEL   "gpio_test.hex"
`define RAM_HEX_VERILOG "gpio_test.mem"

`ifdef RAM
  `define INTEL_HEX   `RAM_HEX_INTEL
  `define VERILOG_HEX `RAM_HEX_VERILOG
`else
  `define INTEL_HEX   `ROM_HEX_INTEL
  `define VERILOG_HEX `ROM_HEX_VERILOG
`endif

module IntelHextoVHex;

localparam MEMSIZE = 8*1024;
localparam RAMSIZE = MEMSIZE / 4;

reg [7:0] mem [MEMSIZE-1:0]; 
reg [31:0] RAM [RAMSIZE-1:0];

integer i;

initial begin
    $readmemh(`INTEL_HEX, mem);
    for (i = 0; i < RAMSIZE; i = i + 1) begin
        RAM[i] = ({24'b0, mem[i*4 + 3]} << 24) | 
                 ({24'b0, mem[i*4 + 2]} << 16) | 
                 ({24'b0, mem[i*4 + 1]} << 8)  | 
                 (mem[i*4]);
    end
    
    $writememh(`VERILOG_HEX, RAM);
    
end

endmodule