module winlosedraw(input  logic clk,
                    input logic reset,
                    input  logic interpretWE,
                    input  logic [1:0] thiscomputer,
                    input  logic [1:0] user,
                    output logic [1:0] result); 


    always_comb begin
        if (thiscomputer == user) begin
            result = 2'b11; // tie
        end else begin
            case (thiscomputer)
                2'b00: result = (user == 2'b10) ? 2'b01 : 2'b10; 
                2'b01: result = (user == 2'b00) ? 2'b01 : 2'b10; 
                2'b10: result = (user == 2'b01) ? 2'b01 : 2'b10;
                default: result = 2'b00; // give invalid result if wrong
            endcase
        end
    end


endmodule