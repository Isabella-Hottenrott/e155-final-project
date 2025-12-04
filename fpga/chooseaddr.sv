module chooseaddr(input logic clk,
                input logic reset,
                input logic screenWE,
                input logic [5:0] directedBits,
                input logic [1:0] thiscomputer,
                input logic [1:0] result,
                output logic [5:0] screencode);

logic [6:0] screencodeintermed;

#define rstScreen 00000111
#define startScreen 00001011
#define plcMoveScreen 00001111
#define dsplCompScreen 10010011
#define dsplWinLoseScreen 10100011
#define nextrndScreen 01000011
#define tenDoneScreen 01000111


always_comb begin
    case(directedBits) // can change all these values once addresses are agreed on
        6'b000001: screencodeintermed = directedBits; // reset
        6'b000010: screencodeintermed = directedBits; // start
        6'b000011: screencodeintermed = directedBits; // place your move
        6'b010000: screencodeintermed = directedBits; // play next round
        6'b010001: screencodeintermed = directedBits; // 10 rounds done
        6'b100100: screencodeintermed = directedBits + thiscomputer; // will take up
                                                              // 7'b0000101 (computer rock)
                                                              // 7'b0000110 (computer paper)        
                                                              // 7'b0000111 (computer scissors)
        6'b101000: screencodeintermed = directedBits + result;       // will take up
                                                              // 7'b1001001 (computer win)
                                                              // 7'b1001010 (computer lose)        
                                                              // 7'b1001011 (computer draw)
        default:    screencodeintermed = 6'b000000;
    endcase
end


always @(posedge clk) begin
if (reset)
screencode <= 6'b0;
else if (screenWE)
screencode <= screencodeintermed;
else
screencode <= screencode;
end


endmodule
