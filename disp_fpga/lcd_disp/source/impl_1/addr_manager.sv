// Wava Chan
// Nov 2025
// Keeping track of image addresses in external flash memory & generates address to read from

module addr_manager(
    input clk,
    input start,
    input reset,
    input [3:0] image,
    output done, 
    output reg[23:0] addr
    );
	
	
	//TODO: SET UP THESE ADDRESSES
	logic [23:0] PAPER, ROCK, SCISSORS, WIN, LOSE, TIE;
	int SIZE;
	assign SIZE = 153600; // is this correct syntax?
	assign PAPER = 24'h200000; //2MB offset. example address. to be changed.
	assign ROCK = PAPER + SIZE; //add size of image
	assign SCISSORS = ROCK + SIZE;
	assign WIN = SCISSORS + SIZE;
	assign LOSE = WIN + SIZE;
	assign TIE = LOSE + SIZE;
	

    // On reset, set address to 0
    always @(posedge clk) begin
        if (reset) begin
            addr <= 17'd0;
        end else if (start) begin
            //addr <= addr + 17'd1;
			case(image) //TODO: DOUBLE CHECK THESE
				4'b0000: addr <= PAPER;
				4'b0001: addr <= ROCK;
				4'b0010: addr <= SCISSORS;
				4'b0011: addr <= WIN;
				4'b0100: addr <= LOSE;
				4'b0101: addr <= TIE;
				default: addr <= 24'h100000; //TODO: implement addr check where we send all 0s if no address
			endcase
        end
    end

endmodule