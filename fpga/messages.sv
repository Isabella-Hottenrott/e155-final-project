// Wava Chan 
// Nov 2025
// stores all messages in ROM using EBR dual-port RAM

module messages(
    input  logic        clk, // 0-255 Message ID
    input  logic [7:0]  msg_index, // 0-255 Character position within the message
    input  logic [7:0]  char_index,
    output logic [7:0]  data_out,
    output logic        valid_out
);

	// ---------------------------------------------------------
	// 1. Address Calculation (160-bit / 20-char Mode)
	// ---------------------------------------------------------
	// We are storing 20 characters (bytes) per 160-bit RAM row.
	// To find the Row: Divide char_index by 20.
	// To find the Byte: Take char_index mod 20.

	// Assumption: Fixed 20-character blocks per message.
	// 20 chars per row = 1 row per message.

	// NOTE: With 512 deep RAM, you can store 512/3 = 170 full messages.
	logic [8:0] rd_addr;

	always_comb begin
		logic [8:0] char_index_div20;
		char_index_div20 = char_index % 20;

		rd_addr = msg_index + char_index_div20;
	end

    // ---------------------------------------------------------
    // 2. RAM Instantiation (Read-Only Mode)
    // ---------------------------------------------------------
    logic [159:0] ram_rd_data;

    message_writer ebr_inst (
        .wr_clk_i(clk),
        .rd_clk_i(clk),
        .rst_i(1'b0),
        .wr_clk_en_i(1'b0),
        .rd_en_i(1'b1),
        .rd_clk_en_i(1'b1),
        .wr_en_i(1'b0),
        .wr_data_i(160'b0),      // 160-bit zero write data
        .wr_addr_i(9'b0),
        .rd_addr_i(rd_addr),
        .rd_data_o(ram_rd_data) // 160-bit read output
    );

    // ---------------------------------------------------------
    // 3. Pipelining for Latency
    // ---------------------------------------------------------
    // 1 cycle latency compensation.
    // We need 3 bits to select one of 8 bytes (0-7).
    
    logic [7:0] byte_select_reg;
    logic       valid_reg;

    always_ff @(posedge clk) begin
        byte_select_reg <= char_index;
        valid_reg       <= 1'b1; 
    end

    // ---------------------------------------------------------
    // 4. Output Muxing
    // ---------------------------------------------------------
    // Select the byte corresponding to the delayed char_index
    // Memory Layout: [Byte7][Byte6]...[Byte1][Byte0]
    
    always_comb begin
        case(byte_select_reg)
			4'd0:  data_out = ram_rd_data[7:0];
			4'd1:  data_out = ram_rd_data[15:8];
			4'd2:  data_out = ram_rd_data[23:16];
			4'd3:  data_out = ram_rd_data[31:24];
			4'd4:  data_out = ram_rd_data[39:32];
			4'd5:  data_out = ram_rd_data[47:40];
			4'd6:  data_out = ram_rd_data[55:48];
			4'd7:  data_out = ram_rd_data[63:56];
			4'd8:  data_out = ram_rd_data[71:64];
			4'd9:  data_out = ram_rd_data[79:72];
			4'd10: data_out = ram_rd_data[87:80];
			4'd11: data_out = ram_rd_data[95:88];
			4'd12: data_out = ram_rd_data[103:96];
			4'd13: data_out = ram_rd_data[111:104];
			4'd14: data_out = ram_rd_data[119:112];
			4'd15: data_out = ram_rd_data[127:120];
			4'd16: data_out = ram_rd_data[135:128];
			4'd17: data_out = ram_rd_data[143:136];
			4'd18: data_out = ram_rd_data[151:144];
			4'd19: data_out = ram_rd_data[159:152];
			default: data_out = 8'h00;
		endcase
	end
	assign valid_out = valid_reg;
	
endmodule