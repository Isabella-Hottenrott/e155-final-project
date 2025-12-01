// Wava Chan
// Nov 2025
// SPI Flash Reader Module
// Reads pixel data from SPI flash and provides it to the display driver

module flash_reader(
    input  logic        clk,            // System Clock (e.g., 48MHz)
    input  logic        reset,
    input  logic        start_read,     // Trigger from system to begin load
    input  logic        buffer_full,    // From SPRAM FIFO (Pause signal)
    input logic [23:0]  START_ADDRESS, // 24-bit start address in flash

    // W25Q32JV Interface
    output logic        flash_cs_n,     // Chip Select (Active Low)
    output logic        flash_sclk,     // Serial Clock
    output logic        flash_mosi,     // Master Out Slave In
    input  logic        flash_miso,     // Master In Slave Out
    
    // Output to SPRAM Line Buffer
    output logic [15:0] flash_data_out, // 16-bit pixel data
    output logic        data_valid_out  // Pulse high when 16 bits are ready
);

    // -------------------------------------------------------------------------
    // Parameters and Typedefs
    // -------------------------------------------------------------------------
    typedef enum {
        STATE_IDLE,
        STATE_CMD,      // Send 0x0B Fast Read Command
        STATE_ADDR,     // Send 24-bit Address
        STATE_DUMMY,    // Send 1 Dummy Byte
        STATE_READ_DATA
    } flash_state_t;

    flash_state_t state, next_state;

    // Fast Read Command, starting address, etc.
    localparam FLASH_CMD_FAST_READ = 8'h0B;
    //localparam START_ADDRESS = 24'h000000; // Start of image data

    // -------------------------------------------------------------------------
    // SPI SCLK Generation (using the CLK_DIV logic from above)
    // -------------------------------------------------------------------------
    // For 12MHz SCLK from 48MHz clock:
    localparam SCLK_DIV = 2; 

    logic [SCLK_DIV-1:0] sclk_count;
    logic sclk_toggle;
    
    // Clock gating logic: sclk_enable is only 1 when we are not paused.
    logic sclk_enable;
    assign sclk_enable = !((state == STATE_READ_DATA) && buffer_full);
    
    always_ff @(posedge clk) begin
        if (reset) begin
            sclk_count  <= 0;
            sclk_toggle <= 1'b0;
        end else if (sclk_count == SCLK_DIV - 1) begin
            sclk_count  <= 0;
            sclk_toggle <= ~sclk_toggle;
        end else if (sclk_enable) begin
            sclk_count  <= sclk_count + 1;
        end
    end
    assign flash_sclk = sclk_toggle;


    // -------------------------------------------------------------------------
    // Shifter, Counter, and Data Buffers
    // -------------------------------------------------------------------------
    logic [7:0]  spi_tx_data;      // Data to transmit (MOSI)
    logic [7:0]  spi_rx_byte;      // Received byte (MISO)
    logic [2:0]  bit_count;        // 8 bits per byte
    logic [7:0]  byte_buffer;      // Holds the first byte of a 16-bit word
    logic        byte_toggle;      // 0 = low byte, 1 = high byte (for packing)
    logic [5:0]  cmd_bit_counter;  // Tracks 32 bits for CMD/ADDR/DUMMY

    // MISO Sampling Edge: Sample on the falling edge of SCLK
    logic sample_miso;
    assign sample_miso = sclk_toggle == 1'b1 && sclk_count == SCLK_DIV - 2; 
    
    // MOSI Driving Edge: Drive on the falling edge of SCLK
    assign flash_mosi = spi_tx_data[7 - bit_count]; // MSB first


    // -------------------------------------------------------------------------
    // Main FSM and Data Flow
    // -------------------------------------------------------------------------
    always_ff @(posedge clk) begin
        if (reset) begin
            state         <= STATE_IDLE;
            flash_cs_n    <= 1'b1;
            data_valid_out <= 1'b0;
            cmd_bit_counter <= 0;
            bit_count     <= 0;
            byte_toggle   <= 0;
            next_state    <= STATE_IDLE;
        end else begin
            data_valid_out <= 1'b0; // Default low
            next_state = state; // Default assignment to prevent latching

            // MISO Data Shifting
            if (sclk_enable && sample_miso) begin
                spi_rx_byte <= {spi_rx_byte[6:0], flash_miso};
                bit_count   <= bit_count + 1;
            end

            // Main State Transitions
            case (state)
                STATE_IDLE: begin
                    flash_cs_n <= 1'b1;
                    if (start_read) begin
                        flash_cs_n <= 1'b0; // Activate chip
                        spi_tx_data <= FLASH_CMD_FAST_READ;
                        next_state <= STATE_CMD;
                        cmd_bit_counter <= 0; // Reset counter for 4 bytes of command/address/dummy
                    end
                end

                STATE_CMD, STATE_ADDR, STATE_DUMMY: begin
                    // Check if 8 bits are done
                    if (bit_count == 7) begin
                        bit_count <= 0;
                        cmd_bit_counter <= cmd_bit_counter + 1;
                        
                        // Transition logic based on byte count
                        case (cmd_bit_counter)
                            0: begin next_state <= STATE_ADDR; spi_tx_data <= START_ADDRESS[23:16]; end // High Address Byte
                            1: begin next_state <= STATE_ADDR; spi_tx_data <= START_ADDRESS[15:8]; end  // Mid Address Byte
                            2: begin next_state <= STATE_ADDR; spi_tx_data <= START_ADDRESS[7:0]; end   // Low Address Byte
                            3: begin next_state <= STATE_DUMMY; spi_tx_data <= 8'h00; end                // Dummy Byte
                            4: begin next_state <= STATE_READ_DATA; end                                  // Ready to Read
                            default: next_state <= STATE_READ_DATA;
                        endcase
                    end
                end

                STATE_READ_DATA: begin
                    // PAUSE LOGIC: Stop shifting/toggling if buffer is full
                    if (buffer_full) begin
                        // Hold SCLK, MISO, and bit_count until buffer is clear
                        // We rely on sclk_enable = 0 to gate the clock and bit_count increment
                    end else if (bit_count == 7) begin
                        // Full Byte Received (8 bits)
                        bit_count <= 0;
                        
                        // Word Packing Logic
                        if (byte_toggle == 1'b0) begin
                            // First byte of the 16-bit word (LSB)
                            byte_buffer <= spi_rx_byte;
                            byte_toggle <= 1'b1;
                        end else begin
                            // Second byte of the 16-bit word (MSB) -> Ready to send
                            flash_data_out <= {spi_rx_byte, byte_buffer}; // MSB, LSB
                            data_valid_out <= 1'b1;
                            byte_toggle <= 1'b0;
                        end
                    end
                end
            endcase
            state <= next_state;
        end
    end
endmodule