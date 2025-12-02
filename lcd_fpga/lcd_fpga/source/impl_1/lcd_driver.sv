// Wava Chan
// Nov 2025
// Driver for the WH2002AE-1 LCD

module lcd_driver(
	//input logic [3:0] screen, //TO BE IMPLEMENTED
	input logic reset,
	input logic change_screen,
	output logic [7:0] DB, //data bus
	output logic rs,
	output logic rw, //read/write. high = read, low = write
	output logic en // chip enable
	);

	//Create clock. might be deleted/passed in later
	
	logic int_osc; // internal clock
	logic [20:0] counter;
	HSOSC #(.CLKHF_DIV(2'b00)) //48MHz
		hf_osc (.CLKHFPU(1'b1), .CLKHFEN(1'b1), .CLKHF(int_osc));
	always_ff @(posedge int_osc) begin  
		counter <= counter + 20'd3; //operates at ~137Hz. you could get closer to 120Hz by changing to 21'd5 but this is close enough
	end
	logic clk = counter[20]; //TODO: i do not know at what rate this is supposed to be at. maybe 100MHz? but we can't do that
	
	// set up internal logic 
	typedef enum {
        START, // start/idle
		CLEAR, // clear screen
		CURSOR_HOME, //return the cursor to home
		WRITE_SCREEN
    } state_t;

    state_t state, next_state;
	
	// write display data to storage
	logic [7:0] msg_index, char_index, data; // character in message?
	logic valid;
	
	
	messages mes( //essentially a wrapper for the EBR_DP block
		.clk(clk), 
		.msg_index(msg_index), // message?
		.char_index(char_index), // character in message?
		.data(data), // actual data
		.valid(valid)
	);
	
	//should this be it's own module? use the RAM_DP IP block
	

	
	// state machine
	always_ff @(posedge clk) begin
		if (reset) begin
			state <= START;
		end
		else begin
			state <= next_state;
			end 
		
		// state transitions
		case (state)
			START: begin
				next_state <= CLEAR;
			end
			CLEAR: begin 
				next_state <= CURSOR_HOME;
			end
			CURSOR_HOME: begin
				next_state <= WRITE_SCREEN;
			end
			WRITE_SCREEN: begin
					if(change_screen) next_state <= CLEAR;
					else next_state <= WRITE_SCREEN;
				end
			default: next_state <= START;
		endcase
	end
	
	//assign output logic
	always_ff @(posedge clk) begin
		case(state)
			START: begin
				
			end
			CLEAR: begin 
				rs <= 0;
				rw <= 0;
				DB <= 8'b00000001; 
				
			end
			CURSOR_HOME: begin
				rs <= 0;
				rw <= 0;
				DB <= 8'b00000010; 
			end
			WRITE_SCREEN: begin
					//write correct image DB data
				end
			//default: 
		endcase
	end
		
	
	// grab data for displays 
	
	
	
	
endmodule