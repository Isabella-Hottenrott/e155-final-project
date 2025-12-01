// Wava Chan + Bella Hottentrot
// Nov. 2025
// E155 Final Project
// SPI Interface Module

module finalproj(input logic sck,
                input logic sdi,
                input logic cs,
                input logic reset,
                output logic [2:0] LED);

logic done, interpretWE, screenWE;
logic [7:0] unsynchSPIbyte, synchSPIbyte;
logic [6:0] directedBits;

//try new way next

spi spi(.sck(sck), .sdi(sdi), .cs(cs), .byteOut(unsynchSPIbyte), .done(spiInDone));
synchronizer(.clk(clk), .byteIn(unsynchSPIbyte), .reset(reset), .byteOutSynch(synchSPIbyte));
mcuMux(.byteIn(synchSPIbyte), .interpretWE(interpretWE), .screenWE(screenWE), .out(directedBits));





endmodule
