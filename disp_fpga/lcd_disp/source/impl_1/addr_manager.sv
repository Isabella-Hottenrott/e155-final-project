// Wava Chan
// Nov 2025
// Keeping track of image addresses in external flash memory & generates address to read from

module addr_manager(
    input clk,
    input start,
    input reset,
    input [2:0] image,
    output done, 
    output reg[16:0] addr
    );
	
	
	//TODO: SET UP THESE ADDRESSES
	logic [16:0] PAPER, ROCK, SCISSORS, WIN, LOSE, TIE;
	int SIZE;
	assign SIZE = 153600; // is this correct syntax?
	assign PAPER = 17'h2000; //example address. to be changed.
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
				3'b000: addr <= PAPER;
				3'b001: addr <= ROCK;
				3'b010: addr <= SCISSORS;
				3'b011: addr <= WIN;
				3'b100: addr <= LOSE;
				3'b101: addr <= TIE;
				default: addr <= 17'd0; //TODO: implement addr check where we send all 0s if no address
			endcase
        end
    end

endmodule