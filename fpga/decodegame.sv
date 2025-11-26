module decodegame(input  logic clk,
                    input logic [7:0] byteInSynch,
                    output logic [1:0] winLoseDraw); 

    logic [1:0] user, computer;

    assign user = byteInSynch[7:6];
    assign computer = byteInSynch[5:4];


assign winLoseDraw[1] = user[1]&computer[1] | ~user[1]&user[0]&~computer[1]&computer[0] |~(|user,computer);
assign winLoseDraw[0] = ~user[1]&user[0]&computer[1] | user[1]&(~(|computer)) | ~computer[1]&computer[0]&(~(|user));





endmodule