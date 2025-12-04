// Wava Chan 
// Nov 2025
// stores all messages in ROM using EBR dual-port RAM

module messages(
    input  logic        clk, // 0-255 Message ID
    input  logic [2:0]  msg_index, // 0-255 Character position within the message
    input  logic [7:0]  char_index,
    output logic [7:0]  data_out,
    output logic        valid_out
);

	// ---------------------------------------------------------
	// 1. Address Calculation (160-bit / 20-char Mode)
	// ---------------------------------------------------------
	// We are storing 20 characters (bytes) per 160-bit RAM row.
	// Each message takes exactly 1 row (20 chars = 160 bits).
	// Address = msg_index (since each message is 1 row)
	// Byte selection within row = char_index (0-19)

	// NOTE: With 512 addresses, you can store 512 full messages.
	logic [8:0] rd_addr;

	always_comb begin
		rd_addr <= msg_index; // Message index is the row address
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
        .wr_addr_i(3'b0),
        .rd_addr_i(msg_index),
        .rd_data_o(ram_rd_data) // 160-bit read output
    );

    // ---------------------------------------------------------
    // 3. Pipelining for LatencyS
    // ---------------------------------------------------------
    // 1 cycle latency compensation.
    // Store char_index to select byte within 160-bit word
    
    logic [7:0] byte_select_reg;
    logic       valid_reg; // i think this signal does not do anything lol

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
        case(char_index)
			8'd0:  data_out = ram_rd_data[7:0];
			8'd1:  data_out = ram_rd_data[15:8];
			8'd2:  data_out = ram_rd_data[23:16];
			8'd3:  data_out = ram_rd_data[31:24];
			8'd4:  data_out = ram_rd_data[39:32];
			8'd5:  data_out = ram_rd_data[47:40];
			8'd6:  data_out = ram_rd_data[55:48];
			8'd7:  data_out = ram_rd_data[63:56];
			8'd8:  data_out = ram_rd_data[71:64];
			8'd9:  data_out = ram_rd_data[79:72];
			8'd10: data_out = ram_rd_data[87:80];
			8'd11: data_out = ram_rd_data[95:88];
			8'd12: data_out = ram_rd_data[103:96];
			8'd13: data_out = ram_rd_data[111:104];
			8'd14: data_out = ram_rd_data[119:112];
			8'd15: data_out = ram_rd_data[127:120];
			8'd16: data_out = ram_rd_data[135:128];
			8'd17: data_out = ram_rd_data[143:136];
			8'd18: data_out = ram_rd_data[151:144];
			8'd19: data_out = ram_rd_data[159:152];
			default: data_out = 8'h00;
		endcase
	end
	assign valid_out = valid_reg;
	
endmodule