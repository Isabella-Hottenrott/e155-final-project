module winlosedraw(input  logic clk,
                        input logic reset,
                        input  logic interpretWE,
                        input  logic [1:0] computer,
                        input  logic [1:0] user,
                        output logic [5:0] gameState); 

assign gameState[5:4] = user;
assign gameState[3:2] = computer;

assign gameState[0] = (~|user)&(~computer[1])|((~user[1]&user[0])&^computer)|((user[1]&~user[0])&(~computer[0]));
assign gameState[1] = (~|user)&(~computer[0])|((~user[1]&user[0])&(~computer[1]))|((user[1]&~user[0])&(^computer));

//try new way next


endmodule