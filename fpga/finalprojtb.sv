module finalprojtb();
    logic clk, reset;
    logic sck, sdi, cs;
    logic [2:0] LED, LEDexp;
    logic [4:0] errors, vectornum;

    finalproj dut(.sck(sck), .sdi(sdi), .cs(cs), .reset(reset), .LED(LED));


    always
        begin
            clk=1; #5;
            clk=0; #5;
        end


       
    initial begin
            errors=0; vectornum=5'd0; #10; reset=1'b0; #10;
            vectornum=5'd1; sck=1'b1; cs=1'b1; sdi=1'b1; LEDexp=3'b000; #10;  
            vectornum=5'd2; sck=1'b0; cs=1'b1; sdi=1'b1; LEDexp=3'b000; #10;
            vectornum=5'd3; sck=1'b1; cs=1'b1; sdi=1'b0; LEDexp=3'b000; #10;
            vectornum=5'd4; sck=1'b0; cs=1'b1; sdi=1'b0; LEDexp=3'b000; #10;
            vectornum=5'd5; sck=1'b1; cs=1'b1; sdi=1'b0; LEDexp=3'b000; #10;
            vectornum=5'd6; sck=1'b0; cs=1'b1; sdi=1'b0; LEDexp=3'b000; #10;
            vectornum=5'd7; sck=1'b1; cs=1'b1; sdi=1'b0; LEDexp=3'b000; #10;
            vectornum=5'd8; sck=1'b0; cs=1'b1; sdi=1'b0; LEDexp=3'b000; #10;
            vectornum=5'd9; sck=1'b1; cs=1'b1; sdi=1'b0; LEDexp=3'b000; #10;
            vectornum=5'd10; sck=1'b0; cs=1'b1; sdi=1'b0; LEDexp=3'b000; #10;
            vectornum=5'd11; sck=1'b1; cs=1'b1; sdi=1'b0; LEDexp=3'b000; #10;
            vectornum=5'd12; sck=1'b0; cs=1'b1; sdi=1'b0; LEDexp=3'b000; #10;
            vectornum=5'd13; sck=1'b1; cs=1'b1; sdi=1'b0; LEDexp=3'b000; #10;
            vectornum=5'd14; sck=1'b0; cs=1'b1; sdi=1'b0; LEDexp=3'b000; #10;
            vectornum=5'd15; sck=1'b1; cs=1'b1; sdi=1'b0; LEDexp=3'b000; #10;
            vectornum=5'd16; sck=1'b0; cs=1'b1; sdi=1'b0; LEDexp=3'b000; #10;

            vectornum=5'd17; sck=1'b0; cs=1'b0; sdi=1'b0; LEDexp=3'b100; #10;
            vectornum=5'd18; sck=1'b0; cs=1'b0; sdi=1'b0; LEDexp=3'b100; #10;
            vectornum=5'd19; sck=1'b0; cs=1'b0; sdi=1'b0; LEDexp=3'b100; #10;
            vectornum=5'd20; sck=1'b0; cs=1'b0; sdi=1'b0; LEDexp=3'b100; #10;
            vectornum=5'd21; sck=1'b0; cs=1'b0; sdi=1'b0; LEDexp=3'b100; #10;
            vectornum=5'd22; sck=1'b0; cs=1'b0; sdi=1'b0; LEDexp=3'b100; #10;
            #10;
            #10;
            vectornum=5'd23; sck=1'b1; cs=1'b1; sdi=1'b0; LEDexp=3'b000; #10;  
            vectornum=5'd24; sck=1'b0; cs=1'b1; sdi=1'b0; LEDexp=3'b000; #10;
            vectornum=5'd25; sck=1'b1; cs=1'b1; sdi=1'b1; LEDexp=3'b000; #10; 
            vectornum=5'd26; sck=1'b0; cs=1'b1; sdi=1'b1; LEDexp=3'b000; #10;
            vectornum=5'd27; sck=1'b1; cs=1'b1; sdi=1'b0; LEDexp=3'b000; #10;
            vectornum=5'd28; sck=1'b0; cs=1'b1; sdi=1'b0; LEDexp=3'b000; #10;
            vectornum=5'd29; sck=1'b1; cs=1'b1; sdi=1'b0; LEDexp=3'b000; #10;
            vectornum=5'd30; sck=1'b0; cs=1'b1; sdi=1'b0; LEDexp=3'b000; #10;
            vectornum=5'd31; sck=1'b1; cs=1'b1; sdi=1'b0; LEDexp=3'b000; #10;
            vectornum=5'd32; sck=1'b0; cs=1'b1; sdi=1'b0; LEDexp=3'b000; #10;
            vectornum=5'd33; sck=1'b1; cs=1'b1; sdi=1'b0; LEDexp=3'b000; #10;
            vectornum=5'd34; sck=1'b0; cs=1'b1; sdi=1'b0; LEDexp=3'b000; #10;
            vectornum=5'd35; sck=1'b1; cs=1'b1; sdi=1'b0; LEDexp=3'b000; #10;
            vectornum=5'd36; sck=1'b0; cs=1'b1; sdi=1'b0; LEDexp=3'b000; #10;
            vectornum=5'd37; sck=1'b1; cs=1'b1; sdi=1'b0; LEDexp=3'b000; #10;
            vectornum=5'd38; sck=1'b0; cs=1'b1; sdi=1'b0; LEDexp=3'b000; #10;

            vectornum=5'd39; sck=1'b0; cs=1'b0; sdi=1'b0; LEDexp=3'b010; #10;
            vectornum=5'd40; sck=1'b0; cs=1'b0; sdi=1'b0; LEDexp=3'b010; #10;
            vectornum=5'd41; sck=1'b0; cs=1'b0; sdi=1'b0; LEDexp=3'b010; #10;
            vectornum=5'd42; sck=1'b0; cs=1'b0; sdi=1'b0; LEDexp=3'b010; #10;
            vectornum=5'd43; sck=1'b0; cs=1'b0; sdi=1'b0; LEDexp=3'b010; #10;
            vectornum=5'd44; sck=1'b0; cs=1'b0; sdi=1'b0; LEDexp=3'b010; #10;

            #10;
            #10;

            vectornum=5'd45; sck=1'b1; cs=1'b1; sdi=1'b0; LEDexp=3'b000; #10;  
            vectornum=5'd46; sck=1'b0; cs=1'b1; sdi=1'b0; LEDexp=3'b000; #10;
            vectornum=5'd47; sck=1'b1; cs=1'b1; sdi=1'b0; LEDexp=3'b000; #10;
            vectornum=5'd48; sck=1'b0; cs=1'b1; sdi=1'b0; LEDexp=3'b000; #10;
            vectornum=5'd49; sck=1'b1; cs=1'b1; sdi=1'b1; LEDexp=3'b000; #10; 
            vectornum=5'd50; sck=1'b0; cs=1'b1; sdi=1'b1; LEDexp=3'b000; #10;
            vectornum=5'd51; sck=1'b1; cs=1'b1; sdi=1'b0; LEDexp=3'b000; #10;
            vectornum=5'd52; sck=1'b0; cs=1'b1; sdi=1'b0; LEDexp=3'b000; #10;
            vectornum=5'd53; sck=1'b1; cs=1'b1; sdi=1'b0; LEDexp=3'b000; #10;
            vectornum=5'd54; sck=1'b0; cs=1'b1; sdi=1'b0; LEDexp=3'b000; #10;
            vectornum=5'd55; sck=1'b1; cs=1'b1; sdi=1'b0; LEDexp=3'b000; #10;
            vectornum=5'd56; sck=1'b0; cs=1'b1; sdi=1'b0; LEDexp=3'b000; #10;
            vectornum=5'd57; sck=1'b1; cs=1'b1; sdi=1'b0; LEDexp=3'b000; #10;
            vectornum=5'd58; sck=1'b0; cs=1'b1; sdi=1'b0; LEDexp=3'b000; #10;
            vectornum=5'd59; sck=1'b1; cs=1'b1; sdi=1'b0; LEDexp=3'b000; #10;
            vectornum=5'd60; sck=1'b0; cs=1'b1; sdi=1'b0; LEDexp=3'b000; #10;

            vectornum=5'd61; sck=1'b0; cs=1'b0; sdi=1'b0; LEDexp=3'b001; #10;
            vectornum=5'd62; sck=1'b0; cs=1'b0; sdi=1'b0; LEDexp=3'b001; #10;
            vectornum=5'd63; sck=1'b0; cs=1'b0; sdi=1'b0; LEDexp=3'b001; #10;
            vectornum=5'd64; sck=1'b0; cs=1'b0; sdi=1'b0; LEDexp=3'b001; #10;
            vectornum=5'd65; sck=1'b0; cs=1'b0; sdi=1'b0; LEDexp=3'b001; #10;
            vectornum=5'd66; sck=1'b0; cs=1'b0; sdi=1'b0; LEDexp=3'b001; #10;


            $display("completed with %d errors", errors);
            $stop;
        end
       

    always @(negedge clk)
        if (reset) begin
            if ((LED !== LEDexp)) begin
                $display("Error: on test = %d ", vectornum);
                errors = errors + 1;
            end

end
endmodule