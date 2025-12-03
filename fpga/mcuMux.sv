module mcuMux(input logic [7:0] byteIn,
            output logic interpretWE,
            output logic screenWE,
            output  logic [5:0] directedBits);

assign interpretWE = ~byteIn[1]&byteIn[0];
assign screenWE = byteIn[1]&byteIn[0];

assign directedBits = byteIn[7:2];


endmodule