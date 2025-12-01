module interpretgame(input  logic clk,
                        input logic reset,
                        input  logic interpretWE,
                        input  logic [6:0] directedBits,
                        output logic [1:0] nextComputer,
                        output logic [1:0] WLD); 

logic [1:0] user;
assign WLD = gameState[1:0];

always_ff (@ posedge clk)
    if (reset) begin
        oldwinlose = 2'b00;
        oldcomputer = 2'b00;
        olduser = 2'b00;
    end
    else if (interpretWE) begin
        user = directedBits[6:5];
        oldcomputer = newcomputer;
        oldwinlose = newwinlose;
    end
    else begin
        user = user;
        oldcomputer = oldcomputer;
        oldwinlose = oldwinlose;
    end

computermove computermove(.clk(clk), .reset(reset), .interpretWE(interpretWE), .gameState(gameState), .computer(nextComputer));
winlosedraw winlosedraw(.clk(clk), .reset(reset), interpretWE(interpretWE), .computer(computer), .user(user), .gameState(gameState));





endmodule