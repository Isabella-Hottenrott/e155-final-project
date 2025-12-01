module computermove(input  logic clk,
                        input logic reset,
                        input logic interpretWE,
                        input  logic [5:0] gameState,
                        output logic [1:0] computer); 

logic usrRock, usrPaper, usrScissors, compRock, compPaper, compScissors;
//try new way next

assign usrRock = (~gameState[5])&(~gameState[4]); //00
assign usrPaper = (~gameState[5])&(gameState[4]); //01
assign usrScissors = (gameState[5])&(~gameState[4]); //10

assign compRock = (~gameState[3])&(~gameState[2]); //00
assign compPaper = (~gameState[3])&(gameState[2]); //01
assign compScissors = (gameState[3])&(~gameState[2]); //10

always_comb begin
    casez (gameState[1:0])
        2'b01:   // computer previously won
                if (usrRock) 
                    assign computer = 2'b00;
                else if (usrPaper)
                    assign computer = 2'b01;
                else if (usrScissors)
                    assign computer = 2'b10;
                else
                    assign computer = 2'b11;

        2'b10:  // computer previously lost 
                if (!usrRock) | (!compRock) //nobody chose Rock
                    assign computer = 2'b00;
                else if (!usrPaper) | (!compPaper) //nobody chose Paper
                    assign computer = 2'b01;
                else if (!usrScissors) | (!compScissors) //nobody chose Paper
                    assign computer = 2'b10;
                else
                    assign computer = 2'b11;

        2'b11:  // computer previously tied 
                assign computer = 2'b01; // for now play paper if tied

        default:   computer = 2'b11; // for now computer defaults to wrong input if not working
    endcase
end





endmodule