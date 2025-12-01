module mcuMux(input  logic byteIn,
            output logic interpretWE,
            output logic screenWE,
            output  logic [6:0] out);

assign interpretWE = byteIn[0];
assign screenWE = ~byteIn[0];

assign out = byteIn[7:1];

endmodule