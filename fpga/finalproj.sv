// Wava Chan + Bella Hottentrot
// Nov. 2025
// E155 Final Project
// SPI Interface Module

module finalproj(input logic sck,
                input logic sdi,
                input logic cs,
                input logic reset,
                //output logic [2:0] LED
                output logic [7:0] DB,
                output logic rw,
                output logic rs,
                output logic en
                );

logic done, interpretWE, screenWE;
logic [7:0] unsynchSPIbyte, synchSPIbyte;
logic [6:0] directedBits;

//try new way next
//TODO: figure out the 10 round function

spi spi(.sck(sck), .sdi(sdi), .cs(cs), .byteOut(unsynchSPIbyte), .done(done));

synchronizer synchronizer(.clk(clk), .byteIn(unsynchSPIbyte), .reset(reset), .byteOutSynch(synchSPIbyte));
mcuMux mcuMux(.byteIn(synchSPIbyte), .interpretWE(interpretWE), .screenWE(screenWE), .out(directedBits));
interpretgame interpretgame(.clk(clk), .reset(reset), .interpretWE(interpretWE), .directedBits(directedBits), .thiscomputer(thiscomputer), .result(result));
chooseaddr chooseaddr(.clk(clk), .reset(reset), .screenWE(screenWE), .directedBits(directedBits), .thiscomputer(thiscomputer), .result(result), .screencode(screencode));

lcd_driver lcd_driver(.reset(reset), .screen(screencode), .DB(DB), .change_screen(change_screen), .rw(rw), .rs(rs), .en(en));




endmodule
