module spi(input  logic sck, 
            input  logic sdi,
            input  logic cs,
            output logic [7:0] SIG,
            output logic done,
			output logic start); //TODO change

               
	always@(posedge sdi)
		start = 1'b1;
		
    always_ff @(posedge sck)
        if (cs)  {SIG[7:0]} = {SIG[6:0], sdi};
        else           {SIG} = {SIG}; 

    assign done = ~cs;

endmodule