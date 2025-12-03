module mcuMux(input logic [7:0] byteIn,
            output logic interpretWE,
            output logic screenWE,
            output  logic [6:0] out);

assign interpretWE = byteIn[0];
assign screenWE = ~byteIn[0];
//try new way next
assign out = byteIn[7:1];

endmodule