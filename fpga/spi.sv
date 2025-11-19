module spi(input  logic sck,
            input  logic sdi,
            input  logic cs,
            output logic [7:0] SIG,
            output logic done); //TODO change

               
    // assert load
    // apply 256 sclks to shift in key and plaintext, starting with plaintext[127]
    // then deassert load, wait until done
    // then apply 128 sclks to shift out cyphertext, starting with cyphertext[127]
    // SPI mode is equivalent to cpol = 0, cpha = 0 since data is sampled on first edge and the first
    // edge is a rising edge (clock going from low in the idle state to high).

    always_ff @(posedge sck)
        if (cs)  {SIG[7:0]} = {SIG[6:0], sdi};
        else           {SIG} = {SIG};

    assign done = ~cs;

endmodule