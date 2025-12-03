// Wava Chan + Bella Hottentrot 
// Nov. 2025
// E155 Final Project
// SPI Interface Module

module finalproj(input logic sck,
                input logic sdi,
                input logic cs,
				input logic reset,
				output logic rs,
				output logic rw,
				output logic chip_en,
                output logic [7:0] DB);
				
	
		
	//intermediate logic 
	logic start, done;
	logic [1:0] thiscomputer, result;
	logic interpretWE, screenWE;
	logic [7:0] unsynchSPIbyte, synchSPIbyte;
	logic [6:0] directedBits;
	logic [7:0] screencode;
	/*
		
		
	spi spi(.sck(sck), .sdi(sdi), .cs(cs), .SIG(SIG), .done(done), .start(start));
	//RPStoLED RPStoLED(.sck(sck), .reset(reset), .SIG(SIG), .done(done), .start(start), .LED(LED));
	
	interpretgame(.clk(sck),
				  .reset(reset),
				  .interpretWE(interpretWE),
				  .directedBits(directedBits),
				  .thiscomputer(thiscomp),
				  .result(result)); 
	
	lcd_driver lcd_d( //TODO: add in clock input into here
				.screen(),
				.reset(reset),
				.change_screen(), //TODO: when win-lose-draw finishes, or when 
				.DB(DB), //data bus
				.rs(rs),
				.rw(rw), //read/write. high = read, low = write
				.en(chip_en)); // chip enable
	
	always_ff @(posedge sck) begin
		case(
			
			    //"msg_0": "Rock",
				//"msg_1": "Paper",
				//"msg_2": "Scissors",
				//"msg_3": "You Win!",
				//"msg_4": "You Lose!",
				//"msg_5": "Tie",
				//"msg_6": "Starting...",
				//"msg_7": "Next Level?"
				
	end
	*/
	
	// Clock
		
	logic int_osc; // internal clock
	logic clk; // int_osc clock divided down
	logic [20:0] counter;
	HSOSC #(.CLKHF_DIV(2'b00)) //48MHz
		hf_osc (.CLKHFPU(1'b1), .CLKHFEN(1'b1), .CLKHF(int_osc));
	always_ff @(posedge int_osc) begin  
		counter <= counter + 20'd3; //operates at ~137Hz. you could get closer to 120Hz by changing to 21'd5 but this is close enough
	end
	
	assign clk = counter[20]; //TODO: i do not know at what rate this is supposed to be at. maybe 100MHz? but we can't do that
	


	//try new way next
	//TODO: figure out the 10 round function

	spi spi(.sck(sck), .sdi(sdi), .cs(cs), .byteOut(unsynchSPIbyte), .done(done));

	synchronizer synchronizer(.clk(clk), .byteIn(unsynchSPIbyte), .reset(reset), .byteOutSynch(synchSPIbyte));
	mcuMux mcuMux(.byteIn(synchSPIbyte), .interpretWE(interpretWE), .screenWE(screenWE), .out(directedBits));
	interpretgame interpretgame(.clk(clk), .reset(reset), .interpretWE(interpretWE), .directedBits(directedBits), .thiscomputer(thiscomputer), .result(result));
	chooseaddr chooseaddr(.clk(clk), .reset(reset), .screenWE(screenWE), .directedBits(directedBits), .thiscomputer(thiscomputer), .result(result), .screencode(screencode));

	lcd_driver lcd_driver(.clk(clk), .reset(reset), .screen(screencode), .DB(DB), .change_screen(screenWE), .rw(rw), .rs(rs), .en(chip_en));

		
				
				


endmodule






