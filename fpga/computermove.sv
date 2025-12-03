module computermove(input  logic clk,
                        input logic reset,
                        input logic interpretWE,
                        input  logic [1:0] thisuser,
                        output logic [1:0] thiscomputer);

    logic [1:0] nextcomputer;

    always_ff @(posedge clk) begin
        if (reset) begin
            thiscomputer <= 2'b00;      // start with Rock
        end else if (interpretWE) begin
            thiscomputer <= nextcomputer;  // calc next only when WE
        end
    end


    always_comb begin

        case ({thiscomputer, thisuser})
            // Computer chose Rock
            4'b00_00: nextcomputer = 2'b00; // tie
            4'b00_01: nextcomputer = 2'b10; // lose
            4'b00_10: nextcomputer = 2'b10; // win  

            // Computer chose paper
            4'b01_00: nextcomputer = 2'b00; // win
            4'b01_01: nextcomputer = 2'b01; // tie
            4'b01_10: nextcomputer = 2'b00; // lose

            // Computer chose scissors
            4'b10_00: nextcomputer = 2'b01; // lose
            4'b10_01: nextcomputer = 2'b01; // tie
            4'b10_10: nextcomputer = 2'b10; // win

            default:  nextcomputer = 2'b11; // invalid comp value if none
        endcase
    end






endmodule