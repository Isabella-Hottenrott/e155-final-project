module chooseaddr(input logic clk,
                input logic reset,
                input logic screenWE,
                input logic [6:0] directedBits,
                input logic [1:0] thiscomputer,
                input logic [1:0] result,
                output logic [6:0] screencode);


always_comb begin
    case(directedBits) // can change all these values once addresses are agreed on
        7'b0000010: screencode = directedBits; // reset
        7'b0000011: screencode = directedBits; // start
        7'b0000100: screencode = directedBits; // place your move
        7'b0001000: screencode = directedBits; // play next round
        7'b0111111: screencode = directedBits; // 10 rounds done
        7'b1000101: screencode = directedBits + thiscomputer; // will take up 
                                                              // 7'b0000101 (computer rock)
                                                              // 7'b0000110 (computer paper)        
                                                              // 7'b0000111 (computer scissors)
        7'b1001000: screencode = directedBits + result;       // will take up 
                                                              // 7'b1001001 (computer win)
                                                              // 7'b1001010 (computer lose)        
                                                              // 7'b1001011 (computer draw)
        default:    screencode = 7'b0000000; 
    endcase
end


endmodule
