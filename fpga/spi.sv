module spi(input  logic sck,
input logic clk,
input logic reset,
            input  logic sdi,
            input  logic cs,
            output logic [7:0] byteOut,
            output logic done); //TODO change
logic byteOutWE;
logic [5:0] eightCounter;
logic [9:0] intermedByte;
//try new way next



    always @(posedge sck, posedge reset) begin
if (reset) begin
intermedByte <= 8'b0;;
            eightCounter <= 4'b0;
end
        else if (cs) begin
            {intermedByte[7:0]} <= {intermedByte[6:0], sdi};
            eightCounter <= eightCounter+1;
        end
        else begin
            intermedByte <= intermedByte;
            eightCounter <= 10'b0;
        end
end

assign byteOutWE = ((eightCounter%8)==0);
    assign byteOut = byteOutWE ? intermedByte : 8'b0; // if counter counted to 8, display the value
    assign done = ~cs; // additional signal to know SPI is done

endmodule