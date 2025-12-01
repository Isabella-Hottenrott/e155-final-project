module spi(input  logic sck,
            input  logic sdi,
            input  logic cs,
            output logic [7:0] byteOut,
            output logic done); //TODO change

logic [3:0] eightCounter;
logic [7:0] intermedByte
//try new way next
    always_ff @(posedge sck)
        if (cs)  begin 
            {intermedByte[7:0]} = {intermedByte[6:0], sdi};
            eightCounter = eightCounter+1;
        end
        else begin 
            intermedByte = intermedByte;
            eightCounter = 4'b0;
        end

    assign byteOut = eightCounter[3] ? intermedByte : 8'b0; // if counter counted to 8, display the value
    assign done = ~cs; // additional signal to know SPI is done

endmodule