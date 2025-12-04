module lcdtb();
logic reset, en, rw, rs, clk, int_osc;
logic [2:0] screen, sc;
logic [7:0] DB;
logic [20:0] counter;
logic [4:0] errors, vectornum;
logic [7:0] ctr;

    top dut(.reset(reset), .screen(screen), .DB(DB), .en(en), .rw(rw), .rs(rs));

assign int_osc = dut.int_osc;
assign clk = dut.clk;

`timescale 1ns/1ps;

initial begin 
	reset=0; screen = 2'b00; ctr=0; #61327939; reset=1; #61327939; reset = 0;
	end 
	
	
always @(posedge clk) begin
	
	if (ctr == 8'd250) begin
		ctr <= 5'd0;
		screen = 2'b11;
		end
	else if (ctr == 8'd120)
		screen = 2'b10;
	else if (ctr == 8'd60)
		screen = 2'b11;
	else 
		ctr <= ctr+1;
		end
	
		

endmodule

