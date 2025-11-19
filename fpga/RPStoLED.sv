module RPStoLED(input logic sck,
input logic reset,
                input logic [7:0] SIG,
                input logic done,
input logic start,
                output logic [2:0] LED);

    logic [2:0] RPS;


    always_comb begin
        RPS[2] = SIG[7]; //rock
        RPS[1] = SIG[6]; //paper
        RPS[0] = SIG[5]; //scissors
    end


    always @(posedge done, negedge reset)
if (~reset)
LED = 3'b000;
        else if (done&start) begin
            LED[2] = RPS[2]; //rock
            LED[1] = RPS[1]; //paper
            LED[0] = RPS[0]; //scissors
        end


endmodule