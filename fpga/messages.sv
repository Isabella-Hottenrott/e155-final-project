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
    // 1. Address Calculation (64-bit / 8-char Mode)
    // ---------------------------------------------------------
    // We are storing 8 characters (bytes) per 64-bit RAM row.
    // To find the Row: Divide char_index by 8 (shift right 3).
    // To find the Byte: Take char_index modulo 8 (bottom 3 bits).
    
    // Assumption: Fixed 64-character blocks per message.
    // 64 chars / 8 chars per row = 8 rows per message.
    // Address = (Msg_ID * 8) + (Char_ID / 8)
    
    // NOTE: With 512 deep RAM, you can store 512/8 = 64 full messages.
    logic [8:0] rd_addr;
    
    always_comb begin
        // msg_index * 8 (shift left 3) + char_index / 8 (shift right 3)
        rd_addr = ({1'b0, msg_index} << 3) + (char_index >> 3);
    end

    // ---------------------------------------------------------
    // 2. RAM Instantiation (Read-Only Mode)
    // ---------------------------------------------------------
    logic [63:0] ram_rd_data;

    message_writer ebr_inst (
        .wr_clk_i(clk),
        .rd_clk_i(clk),
        .rst_i(1'b0),
        .wr_clk_en_i(1'b0),
        .rd_en_i(1'b1),
        .rd_clk_en_i(1'b1),
        .wr_en_i(1'b0),
        .wr_data_i(64'b0),      // 64-bit zero write data
        .wr_addr_i(9'b0),
        .rd_addr_i(rd_addr),
        .rd_data_o(ram_rd_data) // 64-bit read output
    );

    // ---------------------------------------------------------
    // 3. Pipelining for Latency
    // ---------------------------------------------------------
    // 1 cycle latency compensation.
    // We need 3 bits to select one of 8 bytes (0-7).
    
    logic [2:0] byte_select_reg;
    logic       valid_reg;

    always_ff @(posedge clk) begin
        // Store bottom 3 bits (0-7) to select byte
        byte_select_reg <= char_index[2:0];
        
        valid_reg       <= 1'b1; 
    end

    // ---------------------------------------------------------
    // 4. Output Muxing
    // ---------------------------------------------------------
    // Select the byte corresponding to the delayed char_index
    // Memory Layout: [Byte7][Byte6]...[Byte1][Byte0]
    
    always_comb begin
        case(byte_select_reg)
            3'b000: data_out = ram_rd_data[7:0];
            3'b001: data_out = ram_rd_data[15:8];
            3'b010: data_out = ram_rd_data[23:16];
            3'b011: data_out = ram_rd_data[31:24];
            3'b100: data_out = ram_rd_data[39:32];
            3'b101: data_out = ram_rd_data[47:40];
            3'b110: data_out = ram_rd_data[55:48];
            3'b111: data_out = ram_rd_data[63:56];
            default: data_out = 8'h00;
        endcase
    end
    
    assign valid_out = valid_reg;
	
endmodule