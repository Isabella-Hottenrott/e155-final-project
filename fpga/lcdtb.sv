module lcdtb();
logic reset, en, rw, rs, clk, int_osc;
logic [2:0] screen, sc;
logic [7:0] DB;
logic [20:0] counter;

    top dut(.reset(reset), .screen(screen), .DB(DB), .en(en), .rw(rw), .rs(rs));

    assign directedBitsDut = dut.directedBits;
    assign interpretWEDut = dut.interpretWE;
    assign screenWEDut = dut.screenWE;
    assign thiscomputerDut = dut.clk;
    assign resultDut = dut.result;    
    assign screencodeDut = dut.screencode;
    assign clkDut = dut.screencode;

`timescale 1ns/1ns;


       
    initial begin
            errors=0; vectornum=5'd0; #10; reset=1'b0; #50; reset = 1'b1; #20; reset=1'b0; #50
            vectornum=5'd1; clk=1'b1; screen=3'b000; #10;  
            vectornum=5'd2; clk=1'b1; screen=3'b000; #10;  
            vectornum=5'd3; clk=1'b1; screen=3'b000; #10;  
            vectornum=5'd4; clk=1'b1; screen=3'b000; #10;  
            vectornum=5'd5; clk=1'b1; screen=3'b000; #10;  
            vectornum=5'd6; clk=1'b1; screen=3'b000; #10;  
            vectornum=5'd7; clk=1'b1; screen=3'b000; #10;  
            vectornum=5'd8; clk=1'b1; screen=3'b000; #10;  
            vectornum=5'd9; clk=1'b1; screen=3'b100; #10;  
            vectornum=5'd10; clk=1'b1; screen=3'b100; #10;  
            vectornum=5'd11; clk=1'b1; screen=3'b100; #10;  
            vectornum=5'd12; clk=1'b1; screen=3'b100; #10;  
            vectornum=5'd13; clk=1'b1; screen=3'b100; #10;  
            vectornum=5'd14; clk=1'b1; screen=3'b100; #10;  
            vectornum=5'd15; clk=1'b1; screen=3'b100; #10;  
            vectornum=5'd16; clk=1'b1; screen=3'b100; #10;  
            vectornum=5'd17; clk=1'b1; screen=3'b000; #10;  
            vectornum=5'd18; clk=1'b1; screen=3'b000; #10;  
            vectornum=5'd19; clk=1'b1; screen=3'b000; #10;  
            vectornum=5'd20; clk=1'b1; screen=3'b000; #10;  
            vectornum=5'd21; clk=1'b1; screen=3'b000; #10;  
            vectornum=5'd22; clk=1'b1; screen=3'b000; #10;  
            vectornum=5'd21; clk=1'b1; screen=3'b000; #10;  
            vectornum=5'd22; clk=1'b1; screen=3'b000; #10; 
            #100;
            vectornum=5'd1; clk=1'b1; screen=3'b000; #10;  
            vectornum=5'd2; clk=1'b1; screen=3'b000; #10;  
            vectornum=5'd3; clk=1'b1; screen=3'b000; #10;  
            vectornum=5'd4; clk=1'b1; screen=3'b000; #10;  
            vectornum=5'd5; clk=1'b1; screen=3'b000; #10;  
            vectornum=5'd6; clk=1'b1; screen=3'b000; #10;  
            vectornum=5'd7; clk=1'b1; screen=3'b000; #10;  
            vectornum=5'd8; clk=1'b1; screen=3'b000; #10;  
            vectornum=5'd9; clk=1'b1; screen=3'b001; #10;  
            vectornum=5'd10; clk=1'b1; screen=3'b001; #10;  
            vectornum=5'd11; clk=1'b1; screen=3'b001; #10;  
            vectornum=5'd12; clk=1'b1; screen=3'b001; #10;  
            vectornum=5'd13; clk=1'b1; screen=3'b001; #10;  
            vectornum=5'd14; clk=1'b1; screen=3'b001; #10;  
            vectornum=5'd15; clk=1'b1; screen=3'b001; #10;  
            vectornum=5'd16; clk=1'b1; screen=3'b001; #10;  
            vectornum=5'd21; clk=1'b1; screen=3'b000; #10;  
            vectornum=5'd22; clk=1'b1; screen=3'b000; #10;  
            vectornum=5'd17; clk=1'b1; screen=3'b000; #10;  
            vectornum=5'd18; clk=1'b1; screen=3'b000; #10;  
            vectornum=5'd19; clk=1'b1; screen=3'b000; #10;  
            vectornum=5'd20; clk=1'b1; screen=3'b000; #10;  
            vectornum=5'd21; clk=1'b1; screen=3'b000; #10;  
            vectornum=5'd22; clk=1'b1; screen=3'b000; #10;  
#100

            $display("completed with %d errors", errors);
            $stop;
        end
       

endmodule
