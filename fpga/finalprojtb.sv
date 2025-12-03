module finalprojtb();
    logic reset;
    logic sck, sdi, cs, clkDut;
    logic interpretWEDut, screenWEDut;
    logic [6:0] directedBitsDut, screencodeDut;
    logic [1:0] thiscomputerDut, resultDut;
    logic [4:0] errors, vectornum;

    finalproj dut(.sck(sck), .sdi(sdi), .cs(cs), .reset(reset), .DB(DB), .rw(rw), .rs(rs), .en(en));

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
            vectornum=5'd1; sck=1'b1; cs=1'b1; sdi=1'b0; #10;  
            vectornum=5'd2; sck=1'b0; cs=1'b1; sdi=1'b0; #10;
            vectornum=5'd3; sck=1'b1; cs=1'b1; sdi=1'b0; #10;
            vectornum=5'd4; sck=1'b0; cs=1'b1; sdi=1'b0; #10;
            vectornum=5'd5; sck=1'b1; cs=1'b1; sdi=1'b0; #10;
            vectornum=5'd6; sck=1'b0; cs=1'b1; sdi=1'b0; #10;
            vectornum=5'd7; sck=1'b1; cs=1'b1; sdi=1'b0; #10;
            vectornum=5'd8; sck=1'b0; cs=1'b1; sdi=1'b0; #10;
            vectornum=5'd9; sck=1'b1; cs=1'b1; sdi=1'b0; #10;
            vectornum=5'd10; sck=1'b0; cs=1'b1; sdi=1'b0; #10;
            vectornum=5'd11; sck=1'b1; cs=1'b1; sdi=1'b1; #10;
            vectornum=5'd12; sck=1'b0; cs=1'b1; sdi=1'b1; #10;
            vectornum=5'd13; sck=1'b1; cs=1'b1; sdi=1'b1; #10;
            vectornum=5'd14; sck=1'b0; cs=1'b1; sdi=1'b1; #10;
            vectornum=5'd15; sck=1'b1; cs=1'b1; sdi=1'b1; #10;
            vectornum=5'd16; sck=1'b0; cs=1'b1; sdi=1'b1; #10;
//rstScreen

            vectornum=5'd17; sck=1'b0; cs=1'b0; sdi=1'b0; #10;
            vectornum=5'd18; sck=1'b0; cs=1'b0; sdi=1'b0; #10;
            vectornum=5'd19; sck=1'b0; cs=1'b0; sdi=1'b0; #10;
            vectornum=5'd20; sck=1'b0; cs=1'b0; sdi=1'b0; #10;
            vectornum=5'd21; sck=1'b0; cs=1'b0; sdi=1'b0; #10;
            vectornum=5'd22; sck=1'b0; cs=1'b0; sdi=1'b0; #10;
            #50;
            #50;
            vectornum=5'd23; sck=1'b1; cs=1'b1; sdi=1'b0; #10;  
            vectornum=5'd24; sck=1'b0; cs=1'b1; sdi=1'b0; #10;
            vectornum=5'd25; sck=1'b1; cs=1'b1; sdi=1'b0; #10;
            vectornum=5'd26; sck=1'b0; cs=1'b1; sdi=1'b0; #10;
            vectornum=5'd27; sck=1'b1; cs=1'b1; sdi=1'b0; #10;
            vectornum=5'd28; sck=1'b0; cs=1'b1; sdi=1'b0; #10;
            vectornum=5'd29; sck=1'b1; cs=1'b1; sdi=1'b0; #10;
            vectornum=5'd30; sck=1'b0; cs=1'b1; sdi=1'b0; #10;
            vectornum=5'd31; sck=1'b1; cs=1'b1; sdi=1'b1; #10;
            vectornum=5'd32; sck=1'b0; cs=1'b1; sdi=1'b1; #10;
            vectornum=5'd33; sck=1'b1; cs=1'b1; sdi=1'b0; #10;
            vectornum=5'd34; sck=1'b0; cs=1'b1; sdi=1'b0; #10;
            vectornum=5'd35; sck=1'b1; cs=1'b1; sdi=1'b1; #10;
            vectornum=5'd36; sck=1'b0; cs=1'b1; sdi=1'b1; #10;
            vectornum=5'd37; sck=1'b1; cs=1'b1; sdi=1'b1; #10;
            vectornum=5'd38; sck=1'b0; cs=1'b1; sdi=1'b1; #10;
//startscreen

            vectornum=5'd39; sck=1'b0; cs=1'b0; sdi=1'b0; #10;
            vectornum=5'd40; sck=1'b0; cs=1'b0; sdi=1'b0; #10;
            vectornum=5'd41; sck=1'b0; cs=1'b0; sdi=1'b0; #10;
            vectornum=5'd42; sck=1'b0; cs=1'b0; sdi=1'b0; #10;
            vectornum=5'd43; sck=1'b0; cs=1'b0; sdi=1'b0; #10;
            vectornum=5'd44; sck=1'b0; cs=1'b0; sdi=1'b0; #10;

            #50;
            #50;

            vectornum=5'd45; sck=1'b1; cs=1'b1; sdi=1'b0; #10;  
            vectornum=5'd46; sck=1'b0; cs=1'b1; sdi=1'b0; #10;
            vectornum=5'd47; sck=1'b1; cs=1'b1; sdi=1'b1; #10;
            vectornum=5'd48; sck=1'b0; cs=1'b1; sdi=1'b1; #10;
            vectornum=5'd49; sck=1'b1; cs=1'b1; sdi=1'b0; #10;
            vectornum=5'd50; sck=1'b0; cs=1'b1; sdi=1'b0; #10;
            vectornum=5'd51; sck=1'b1; cs=1'b1; sdi=1'b0; #10;
            vectornum=5'd52; sck=1'b0; cs=1'b1; sdi=1'b0; #10;
            vectornum=5'd53; sck=1'b1; cs=1'b1; sdi=1'b0; #10;
            vectornum=5'd54; sck=1'b0; cs=1'b1; sdi=1'b0; #10;
            vectornum=5'd55; sck=1'b1; cs=1'b1; sdi=1'b0; #10;
            vectornum=5'd56; sck=1'b0; cs=1'b1; sdi=1'b0; #10;
            vectornum=5'd57; sck=1'b1; cs=1'b1; sdi=1'b1; #10;
            vectornum=5'd58; sck=1'b0; cs=1'b1; sdi=1'b1; #10;
            vectornum=5'd59; sck=1'b1; cs=1'b1; sdi=1'b1; #10;
            vectornum=5'd60; sck=1'b0; cs=1'b1; sdi=1'b1; #10;
// next rnd screen

            vectornum=5'd61; sck=1'b0; cs=1'b0; sdi=1'b0; #10;
            vectornum=5'd62; sck=1'b0; cs=1'b0; sdi=1'b0; #10;
            vectornum=5'd63; sck=1'b0; cs=1'b0; sdi=1'b0; #10;
            vectornum=5'd64; sck=1'b0; cs=1'b0; sdi=1'b0; #10;
            vectornum=5'd65; sck=1'b0; cs=1'b0; sdi=1'b0; #10;
            vectornum=5'd66; sck=1'b0; cs=1'b0; sdi=1'b0; #10;

#50;
#50;

vectornum=5'd45; sck=1'b1; cs=1'b1; sdi=1'b0; #10;  
            vectornum=5'd46; sck=1'b0; cs=1'b1; sdi=1'b0; #10;
            vectornum=5'd47; sck=1'b1; cs=1'b1; sdi=1'b0; #10;
            vectornum=5'd48; sck=1'b0; cs=1'b1; sdi=1'b0; #10;
            vectornum=5'd49; sck=1'b1; cs=1'b1; sdi=1'b0; #10;
            vectornum=5'd50; sck=1'b0; cs=1'b1; sdi=1'b0; #10;
            vectornum=5'd51; sck=1'b1; cs=1'b1; sdi=1'b0; #10;
            vectornum=5'd52; sck=1'b0; cs=1'b1; sdi=1'b0; #10;
            vectornum=5'd53; sck=1'b1; cs=1'b1; sdi=1'b1; #10;
            vectornum=5'd54; sck=1'b0; cs=1'b1; sdi=1'b1; #10;
            vectornum=5'd55; sck=1'b1; cs=1'b1; sdi=1'b1; #10;
            vectornum=5'd56; sck=1'b0; cs=1'b1; sdi=1'b1; #10;
            vectornum=5'd57; sck=1'b1; cs=1'b1; sdi=1'b1; #10;
            vectornum=5'd58; sck=1'b0; cs=1'b1; sdi=1'b1; #10;
            vectornum=5'd59; sck=1'b1; cs=1'b1; sdi=1'b1; #10;
            vectornum=5'd60; sck=1'b0; cs=1'b1; sdi=1'b1; #10;
// next plcMoveScreen

            vectornum=5'd61; sck=1'b0; cs=1'b0; sdi=1'b0; #10;
            vectornum=5'd62; sck=1'b0; cs=1'b0; sdi=1'b0; #10;
            vectornum=5'd63; sck=1'b0; cs=1'b0; sdi=1'b0; #10;
            vectornum=5'd64; sck=1'b0; cs=1'b0; sdi=1'b0; #10;
            vectornum=5'd65; sck=1'b0; cs=1'b0; sdi=1'b0; #10;
            vectornum=5'd66; sck=1'b0; cs=1'b0; sdi=1'b0; #10;

#50;
#50;

vectornum=5'd45; sck=1'b1; cs=1'b1; sdi=1'b1; #10;  
            vectornum=5'd46; sck=1'b0; cs=1'b1; sdi=1'b1; #10;
            vectornum=5'd47; sck=1'b1; cs=1'b1; sdi=1'b0; #10;
            vectornum=5'd48; sck=1'b0; cs=1'b1; sdi=1'b0; #10;
            vectornum=5'd49; sck=1'b1; cs=1'b1; sdi=1'b0; #10;
            vectornum=5'd50; sck=1'b0; cs=1'b1; sdi=1'b0; #10;
            vectornum=5'd51; sck=1'b1; cs=1'b1; sdi=1'b1; #10;
            vectornum=5'd52; sck=1'b0; cs=1'b1; sdi=1'b1; #10;
            vectornum=5'd53; sck=1'b1; cs=1'b1; sdi=1'b0; #10;
            vectornum=5'd54; sck=1'b0; cs=1'b1; sdi=1'b0; #10;
            vectornum=5'd55; sck=1'b1; cs=1'b1; sdi=1'b0; #10;
            vectornum=5'd56; sck=1'b0; cs=1'b1; sdi=1'b0; #10;
            vectornum=5'd57; sck=1'b1; cs=1'b1; sdi=1'b1; #10;
            vectornum=5'd58; sck=1'b0; cs=1'b1; sdi=1'b1; #10;
            vectornum=5'd59; sck=1'b1; cs=1'b1; sdi=1'b1; #10;
            vectornum=5'd60; sck=1'b0; cs=1'b1; sdi=1'b1; #10;
// display comp screen

            vectornum=5'd61; sck=1'b0; cs=1'b0; sdi=1'b0; #10;
            vectornum=5'd62; sck=1'b0; cs=1'b0; sdi=1'b0; #10;
            vectornum=5'd63; sck=1'b0; cs=1'b0; sdi=1'b0; #10;
            vectornum=5'd64; sck=1'b0; cs=1'b0; sdi=1'b0; #10;
            vectornum=5'd65; sck=1'b0; cs=1'b0; sdi=1'b0; #10;
            vectornum=5'd66; sck=1'b0; cs=1'b0; sdi=1'b0; #10;

#50;
#50;


vectornum=5'd45; sck=1'b1; cs=1'b1; sdi=1'b0; #10;  
            vectornum=5'd46; sck=1'b0; cs=1'b1; sdi=1'b0; #10;
            vectornum=5'd47; sck=1'b1; cs=1'b1; sdi=1'b1; #10;
            vectornum=5'd48; sck=1'b0; cs=1'b1; sdi=1'b1; #10;
            vectornum=5'd49; sck=1'b1; cs=1'b1; sdi=1'b1; #10;
            vectornum=5'd50; sck=1'b0; cs=1'b1; sdi=1'b1; #10;
            vectornum=5'd51; sck=1'b1; cs=1'b1; sdi=1'b0; #10;
            vectornum=5'd52; sck=1'b0; cs=1'b1; sdi=1'b0; #10;
            vectornum=5'd53; sck=1'b1; cs=1'b1; sdi=1'b0; #10;
            vectornum=5'd54; sck=1'b0; cs=1'b1; sdi=1'b0; #10;
            vectornum=5'd55; sck=1'b1; cs=1'b1; sdi=1'b0; #10;
            vectornum=5'd56; sck=1'b0; cs=1'b1; sdi=1'b0; #10;
            vectornum=5'd57; sck=1'b1; cs=1'b1; sdi=1'b0; #10;
            vectornum=5'd58; sck=1'b0; cs=1'b1; sdi=1'b0; #10;
            vectornum=5'd59; sck=1'b1; cs=1'b1; sdi=1'b1; #10;
            vectornum=5'd60; sck=1'b0; cs=1'b1; sdi=1'b1; #10;
// formatPlay  8'b01_10_00_01

            vectornum=5'd61; sck=1'b0; cs=1'b0; sdi=1'b0; #10;
            vectornum=5'd62; sck=1'b0; cs=1'b0; sdi=1'b0; #10;
            vectornum=5'd63; sck=1'b0; cs=1'b0; sdi=1'b0; #10;
            vectornum=5'd64; sck=1'b0; cs=1'b0; sdi=1'b0; #10;
            vectornum=5'd65; sck=1'b0; cs=1'b0; sdi=1'b0; #10;
            vectornum=5'd66; sck=1'b0; cs=1'b0; sdi=1'b0; #10;

#50;
#50;

vectornum=5'd45; sck=1'b1; cs=1'b1; sdi=1'b1; #10;  
            vectornum=5'd46; sck=1'b0; cs=1'b1; sdi=1'b1; #10;
            vectornum=5'd47; sck=1'b1; cs=1'b1; sdi=1'b0; #10;
            vectornum=5'd48; sck=1'b0; cs=1'b1; sdi=1'b0; #10;
            vectornum=5'd49; sck=1'b1; cs=1'b1; sdi=1'b0; #10;
            vectornum=5'd50; sck=1'b0; cs=1'b1; sdi=1'b0; #10;
            vectornum=5'd51; sck=1'b1; cs=1'b1; sdi=1'b1; #10;
            vectornum=5'd52; sck=1'b0; cs=1'b1; sdi=1'b1; #10;
            vectornum=5'd53; sck=1'b1; cs=1'b1; sdi=1'b0; #10;
            vectornum=5'd54; sck=1'b0; cs=1'b1; sdi=1'b0; #10;
            vectornum=5'd55; sck=1'b1; cs=1'b1; sdi=1'b0; #10;
            vectornum=5'd56; sck=1'b0; cs=1'b1; sdi=1'b0; #10;
            vectornum=5'd57; sck=1'b1; cs=1'b1; sdi=1'b1; #10;
            vectornum=5'd58; sck=1'b0; cs=1'b1; sdi=1'b1; #10;
            vectornum=5'd59; sck=1'b1; cs=1'b1; sdi=1'b1; #10;
            vectornum=5'd60; sck=1'b0; cs=1'b1; sdi=1'b1; #10;
// dsplWinLoseScreen

            vectornum=5'd61; sck=1'b0; cs=1'b0; sdi=1'b0; #10;
            vectornum=5'd62; sck=1'b0; cs=1'b0; sdi=1'b0; #10;
            vectornum=5'd63; sck=1'b0; cs=1'b0; sdi=1'b0; #10;
            vectornum=5'd64; sck=1'b0; cs=1'b0; sdi=1'b0; #10;
            vectornum=5'd65; sck=1'b0; cs=1'b0; sdi=1'b0; #10;
            vectornum=5'd66; sck=1'b0; cs=1'b0; sdi=1'b0; #10;

#100

            $display("completed with %d errors", errors);
            $stop;
        end
       

endmodule
