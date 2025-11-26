module synchronizer(input  logic clk,
                    input logic [7:0] byteIn,
                    input logic reset,
                    output logic [7:0] byteOutSynch); 

logic[7:0] intermedByte;

always_ff @(posedge clk)
        if (reset)   
            byteOutSynch = 8'b0;
        else begin 
            intermedByte <= byteIn;
            byteOutSynch <= intermedByte;
        end

endmodule
