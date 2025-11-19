// Wava Chan + Bella Hottentrot
// Nov. 2025
// E155 Final Project
// SPI Interface Module

module finalproj(input logic sck,
                input logic sdi,
                input logic cs,
input logic reset,
                output logic [2:0] LED);

logic done;
logic [7:0] SIG;



        spi spi(.sck(sck), .sdi(sdi), .cs(cs), .SIG(SIG), .done(done));
RPStoLED RPStoLED(.sck(sck), .reset(reset), .SIG(SIG), .done(done), .LED(LED));




endmodule

