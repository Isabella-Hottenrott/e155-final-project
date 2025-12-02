module interpretgame(input  logic clk,
                        input logic reset,
                        input  logic interpretWE,
                        input  logic [6:0] directedBits,
                        output logic [1:0] thiscomputer,
                        output logic [1:0] result); 


logic [1:0] user;


always_ff @(posedge clk) begin
    if (reset) begin
        user <= 2'b00;      // shouldnt matter
    end else if (interpretWE) begin
        user <= directedBits[6:5];
    end
end


computermove computermove(.clk(clk), .reset(reset), .interpretWE(interpretWE), .thisuser(user), .thiscomputer(thiscomputer));
winlosedraw winlosedraw(.clk(clk), .reset(reset), .interpretWE(interpretWE), .thiscomputer(thiscomputer), .user(user), .result(result));



endmodule