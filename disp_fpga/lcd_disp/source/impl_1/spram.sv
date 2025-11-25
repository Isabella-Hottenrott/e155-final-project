// Wava Chan
// Nov 2025
// Wrapper for given spram256 user module
// partially based off of https://github.com/damdoy/ice40_ultraplus_examples/blob/master/spram/top.v
// and referencing https://projectf.io/posts/spram-ice40-fpga/
module spram #(
    WIDTH=16,     // fixed data width: 16-bits
    DEPTH=16384,  // fixed depth: 16K 
    ADDRW=$clog2(DEPTH)
    ) (
    input wire logic clk,
    //input wire logic [3:0] we,
    input wire logic [ADDRW-1:0] addr,
    input wire logic [WIDTH-1:0] data_in,
    output     logic [WIDTH-1:0] data_out
    );
	assign write_en = 1'b0; //never need to write to spram
    SB_SPRAM256KA spram_inst (
        .ADDRESS(addr),
        .DATAIN(data_in),
        .MASKWREN({write_en, write_en, write_en, write_en}),
        .WREN(write_en),
        .CHIPSELECT(1'b1), 
        .CLOCK(clk),
        .STANDBY(1'b0),
        .SLEEP(1'b0),
        .POWEROFF(1'b1),
        .DATAOUT(data_out)
    );
endmodule