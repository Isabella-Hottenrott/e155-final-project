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
				
	/*
		
	//intermediate logic 
	logic start, done;
	logic [7:0] SIG;
	logic interpretWE;
	logic [6:0] directedBits;
	logic [1:0] thiscomp, result;
		
		
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






