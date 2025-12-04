// Wava Chan
// Dec 2025
// Testing of LCD driver module for hardware

module top(input logic reset,
			input logic [2:0] screen,
			output logic [7:0] DB,
			output logic en, rw, rs,
			output logic [2:0] leds);
	
	
	logic [2:0] sc;
	logic cs;
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
		counter <= 21'd0; //operates at ~137Hz. you could get closer to 120Hz by changing to 21'd5 but this is close enough
		clk <= ~clk;
		end else begin
			counter <= counter +1;
			end
		
	end
	
	//testing flags
	//assign leds[0] = clk;
	assign leds[1] = int_osc;
	assign leds[2] = screen[2];

	
	//instantiate lcd_driver
	lcd_driver lcd_d(	.clk(clk),
						.screen(screen),
						.reset(reset),
						//.change_screen(change_sc),
						.DB(DB),
						.rw(rw),
						.rs(rs),
						.en(en),
						.test(leds[0])	);
	
	always_ff @(posedge clk) begin // TODO: should i be using an fsm to simulate the other data?

		//load values into variables
		sc <= screen;
		//leds <= screen;
		//rs <= ~rs; //toggle this for verification of clock 
	end
endmodule