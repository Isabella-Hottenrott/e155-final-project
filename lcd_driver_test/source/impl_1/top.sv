// Wava Chan
// Dec 2025
// Testing of LCD driver module for hardware

module top(input logic reset,
			input logic [2:0] screen,
			//input logic change_sc, // just a button for now, used to cycle thru the screens
			output logic [7:0] DB,
			output logic en, rw, rs);
	
	logic [2:0] sc;
	logic cs;
	
	// set up clock
	logic int_osc; // internal clock
	logic clk; // int_osc clock divided down
	logic [20:0] counter;
	HSOSC #(.CLKHF_DIV(2'b00)) //48MHz
		hf_osc (.CLKHFPU(1'b1), .CLKHFEN(1'b1), .CLKHF(int_osc));
	always_ff @(posedge int_osc) begin  
		counter <= counter + 21'd3; //operates at ~137Hz. you could get closer to 120Hz by changing to 21'd5 but this is close enough
	end
	assign clk = counter[20];
	
	// small state machine to handle screen and change screen
	typedef enum {
		SCREEN0,
        SCREEN1,
		SCREEN2,
		SCREEN3,
		SCREEN4, 
		SCREEN5, 
		SCREEN6, 
		SCREEN7
    } state_t;

    state_t state, next_state;
	
	//instantiate lcd_driver
	lcd_driver lcd_d(	.clk(clk),
						.screen(sc),
						.reset(reset),
						//.change_screen(change_sc),
						.DB(DB),
						.rw(rw),
						.rs(rs),
						.en(en) );
	
	always_ff @(posedge clk) begin // TODO: should i be using an fsm to simulate the other data?
		/*
		case(state)
			SCREEN0: begin if(screen ==  //TODO: fill this out
			SCREEN1: begin if( //TODO: fill this out
			SCREEN2: begin if( //TODO: fill this out
			SCREEN3: begin if( //TODO: fill this out
			SCREEN4: begin if( //TODO: fill this out
			SCREEN5: begin if( //TODO: fill this out
			SCREEN6: begin if( //TODO: fill this out
			SCREEN7: begin if( //TODO: fill this out
		*/
		//load values into variables
		sc <= screen;
		//cs <= change_sc;
	end
	

endmodule