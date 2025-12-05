// Wava Chan & Bella Hottentrot
// Dec 2025
// Top level module for LCD driver for hardware

module top(input logic reset,
			input logic [3:0] screen, // serial input from MCU
			output logic [7:0] DB,
			output logic en, rw, rs,
			output test);
			//output logic [2:0] leds);
	
	logic int_osc;
	// set up clock
	logic clk; // int_osc clock divided down
	logic [20:0] counter;
	HSOSC #(.CLKHF_DIV(2'b00)) //48MHz
		hf_osc (.CLKHFPU(1'b1), .CLKHFEN(1'b1), .CLKHF(int_osc));

	always_ff @(posedge int_osc) begin  
		if (~reset) begin
			counter <= 21'd0;
			clk <= 1'b0;
			end
		else if (counter == 21'd2000) begin
		counter <= 21'd0; 
		clk <= ~clk;
		end else begin
			counter <= counter +1;
			end
		
	end
	logic [3:0] ds  = 4'b0001;
	

	assign test = clk;
	//instantiate lcd_driver
	lcd_driver lcd_d(	.clk(clk),
						.screen(screen),
						.reset(reset),
						.DB(DB),
						.rw(rw),
						.rs(rs),
						.en(en)) ;
	
	//always_ff @(posedge clk) begin // TODO: should i be using an fsm to simulate the other data?

	//end
endmodule