module chooseaddr(input logic clk,
                input logic reset,
                input logic screenWE,
                input logic [5:0] directedBits,
                input logic [1:0] thiscomputer,
                input logic [1:0] result,
                output logic [3:0] screencode);

logic [3:0] screencodeintermed, bitswizzlecomputer, bitswizzleresult;

#define rstScreen 00000111
#define startScreen 00001011
#define plcMoveScreen 00001111
#define dsplCompScreen 10010011
#define dsplWinLoseScreen 10100011
#define nextrndScreen 01000011
#define tenDoneScreen 01000111


assign bitswizzlecomputer = {2'b00, thiscomputer};
assign bitswizzleresult = {2'b00, result};

always_comb begin
    case(directedBits) // can change all these values once addresses are agreed on
        6'b000001: screencodeintermed = 4'b0000; // reset
        6'b000010: screencodeintermed = 4'b0001; // start
        6'b000011: screencodeintermed = 4'b0010; // place your move
        6'b010000: screencodeintermed = 4'b0011; // play next round
        6'b010001: screencodeintermed = 4'b0100; // 10 rounds done
        6'b100100: screencodeintermed = 4'b0101 + bitswizzlecomputer; // will take up
                                                              // 4'b0101 (computer rock)
                                                              // 4'b0110 (computer paper)        
                                                              // 4'b0111 (computer scissors)
        6'b101000: screencodeintermed = 4'b0111 + bitswizzleresult;       // will take up
                                                              // 4'b0111 (computer win)
                                                              // 4'b1000 (computer lose)        
                                                              // 4'b1001 (computer draw)
        default:    screencodeintermed = 4'b0000;
    endcase
end


always @(posedge clk) begin
if (reset)
screencode <= 4'b0;
else if (screenWE)
screencode <= screencodeintermed;
else
screencode <= screencode;
end


endmodule
