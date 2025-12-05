module finalproj(input logic sck,
                input logic sdi,
                input logic chipsel,
                input logic reset,
                output logic [7:0] DB,
                output logic rw,
                output logic rs,
                output logic en,
				output logic test,
				output logic [2:0] three
                );
logic [3:0] screen;
logic done, interpretWE, screenWE, clk;
logic [7:0] unsynchSPIbyte, synchSPIbyte;
logic [5:0] directedBits;
logic [1:0] thiscomputer, result;


//try new way next
//TODO: figure out the 10 round function
// Internal high-speed oscillator
	logic [2:0] sc;
	logic cs;
	logic int_osc;
	// set up clock

	// set up clock
	logic [20:0] counter;
	HSOSC #(.CLKHF_DIV(2'b00)) //48MHz
		hf_osc (.CLKHFPU(1'b1), .CLKHFEN(1'b1), .CLKHF(int_osc));

	always_ff @(posedge int_osc, negedge reset) begin  
		if (~reset) begin
			counter <= 21'd0;
			clk <= 1'b0;
			end
		else if (counter == 21'd383) begin
		counter <= 21'd0; //operates at ~100KHz
		clk <= ~clk;
		end else begin
			counter <= counter +1;
			end
		
	end
		
	
assign test = clk;
assign three = screen[2:0];

spi spi(.sck(sck), .clk(clk), .reset(reset), .sdi(sdi), .chipsel(chipsel), .byteOut(unsynchSPIbyte), .done(done));

synchronizer synchronizer(.clk(clk), .byteIn(unsynchSPIbyte), .reset(reset), .byteOutSynch(synchSPIbyte));
mcuMux mcuMux(.byteIn(synchSPIbyte), .interpretWE(interpretWE), .screenWE(screenWE), .directedBits(directedBits));
interpretgame interpretgame(.clk(clk), .reset(reset), .interpretWE(interpretWE), .directedBits(directedBits), .thiscomputer(thiscomputer), .result(result));
chooseaddr chooseaddr(.clk(clk), .reset(reset), .screenWE(screenWE), .directedBits(directedBits), .thiscomputer(thiscomputer), .result(result), .screen(screen));

lcd_driver lcd_d(.clk(clk), .screen(screen), .reset(reset), .DB(DB), .rw(rw), .rs(rs), .en(en));


endmodule
