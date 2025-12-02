// Wava Chan 
// Nov 2025
// stores all messages in ROM 

module messages(
	input logic clk, 
	input logic [7:0] msg_index, // message?
	input logic [7:0] char_index, // character in message?
	output logic [7:0] data, // actual data
	output logic valid
	);
	
	// internal logic
	
	
	// state machine to write all the data
	
	message_writer __(.wr_clk_i( ),
        .rd_clk_i( ),
        .rst_i( ),
        .wr_clk_en_i( ),
        .rd_en_i( ),
        .rd_clk_en_i( ),
        .wr_en_i( ),
        .wr_data_i( ),
        .wr_addr_i( ),
        .rd_addr_i( ),
        .rd_data_o( ));
	
	
	
	
endmodule