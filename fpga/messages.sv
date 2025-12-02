// Wava Chan 
// Nov 2025
// stores all messages in ROM using EBR dual-port RAM

module messages(
	input logic clk, 
	input logic [7:0] msg_index, // which message (0-255)
	input logic [7:0] char_index, // which character in message (0-255)
	output logic [7:0] data, // character data output
	output logic valid // high when data is valid
	);
	
	// Calculate read address from msg_index and char_index
	// Address format: [msg_index (8 bits) | char_index (1 bit)]
	// This allows up to 256 messages with up to 2 characters each per address
	// (36-bit output = 4.5 bytes per address from 9-bit addressing)
	logic [8:0] rd_addr;
	logic [35:0] rd_data;
	
	// Read address calculation
	// msg_index uses lower 8 bits of address, char_index selects byte within word
	assign rd_addr = {msg_index[8:1], char_index[0]};
	
	// Select the appropriate byte from the 36-bit output
	// 36 bits = 4 full bytes + 4 bits (can store 4 characters per address)
	logic [1:0] byte_select;
	assign byte_select = char_index[2:1];
	
	always_comb begin
		case(byte_select)
			2'b00: data = rd_data[7:0];
			2'b01: data = rd_data[15:8];
			2'b10: data = rd_data[23:16];
			2'b11: data = rd_data[31:24];
		endcase
		valid = (char_index < 8'hFF); // all addresses are valid
	end
	
	// Instantiate the dual-port EBR RAM
	// Set as read-only by disabling writes
	message_writer ebr_inst(
		.wr_clk_i(clk),
		.rd_clk_i(clk),
		.rst_i(1'b0),           // no reset
		.wr_clk_en_i(1'b0),     // disable writes
		.rd_en_i(1'b1),         // always reading
		.rd_clk_en_i(1'b1),     // read clock enabled
		.wr_en_i(1'b0),         // no write enable
		.wr_data_i(36'b0),      // no write data
		.wr_addr_i(9'b0),       // no write address
		.rd_addr_i(rd_addr),    // read from computed address
		.rd_data_o(rd_data)     // read output
	);
	
endmodule