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

logic done, interpretWE, screenWE, clk;
logic [7:0] unsynchSPIbyte, synchSPIbyte;
logic [6:0] directedBits, screencode;


//try new way next
//TODO: figure out the 10 round function
// Internal high-speed oscillator
HSOSC #(.CLKHF_DIV(2'b00))
hf_osc (.CLKHFPU(1'b1), .CLKHFEN(1'b1), .CLKHF(clk));

spi spi(.sck(sck), .clk(clk), .reset(reset), .sdi(sdi), .cs(cs), .byteOut(unsynchSPIbyte), .done(done));

synchronizer synchronizer(.clk(clk), .byteIn(unsynchSPIbyte), .reset(reset), .byteOutSynch(synchSPIbyte));
mcuMux mcuMux(.byteIn(synchSPIbyte), .interpretWE(interpretWE), .screenWE(screenWE), .directedBits(directedBits));
interpretgame interpretgame(.clk(clk), .reset(reset), .interpretWE(interpretWE), .directedBits(directedBits), .thiscomputer(thiscomputer), .result(result));
chooseaddr chooseaddr(.clk(clk), .reset(reset), .screenWE(screenWE), .directedBits(directedBits), .thiscomputer(thiscomputer), .result(result), .screencode(screencode));




endmodule