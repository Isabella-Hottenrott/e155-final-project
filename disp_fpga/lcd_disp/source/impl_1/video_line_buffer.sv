// Wava Chan
// Nov 2025
// Wrapper for given spram256 user module
// partially based off of https://github.com/damdoy/ice40_ultraplus_examples/blob/master/spram/top.v
// and referencing https://projectf.io/posts/spram-ice40-fpga/


module video_line_buffer (
    input  logic        clk,            // System Clock (e.g., 48MHz)
    input  logic        reset,

    // Interface to Flash Reader (The Writer)
    input  logic [15:0] flash_data_in,  // 16-bit pixel from Flash
    input  logic        flash_write_en, // Valid signal from Flash
    output logic        buffer_full,    // Tell Flash to PAUSE if high

    // Interface to Display Driver (The Reader)
    input  logic        display_req,    // Display wants a pixel
    output logic [15:0] display_data_out // Pixel to Display
);

    // -------------------------------------------------------------------------
    // Parameters
    // -------------------------------------------------------------------------
    // 240 pixels * 4 lines = 960 words. 
    // Let's round up to 1024 (2^10) for easy math masking.
    localparam BUFFER_DEPTH_BITS = 10; 
    localparam MAX_COUNT = 1024;
    
    // Stop flash when we are almost full to prevent overflow
    localparam FULL_THRESHOLD = 1000; 

    // -------------------------------------------------------------------------
    // Pointers and Counters
    // -------------------------------------------------------------------------
    logic [BUFFER_DEPTH_BITS-1:0] wr_ptr;
    logic [BUFFER_DEPTH_BITS-1:0] rd_ptr;
    logic [BUFFER_DEPTH_BITS:0]   fifo_count; // Extra bit for full count

    // -------------------------------------------------------------------------
    // Memory Signals
    // -------------------------------------------------------------------------
    logic [13:0] spram_addr; // SPRAM takes 14-bit address
    logic [15:0] spram_wdata;
    logic        spram_wren;
    logic        spram_cs;
    logic [15:0] spram_rdata;

    // -------------------------------------------------------------------------
    // 1. Pointer Logic
    // -------------------------------------------------------------------------
    always_ff @(posedge clk) begin
        if (reset) begin
            wr_ptr <= 0;
            rd_ptr <= 0;
            fifo_count <= 0;
        end else begin
            // Handle Writes
            if (flash_write_en && !buffer_full) begin
                wr_ptr <= wr_ptr + 1;
            end

            // Handle Reads
            if (display_req) begin
                rd_ptr <= rd_ptr + 1;
            end

            // Track how many items are in the FIFO
            // If writing and NOT reading: count++
            // If reading and NOT writing: count--
            // If both or neither: count stays same 
            if ((flash_write_en && !buffer_full) && !display_req)
                fifo_count <= fifo_count + 1;
            else if (display_req && !(flash_write_en && !buffer_full))
                fifo_count <= fifo_count - 1;
        end
    end

    // Signal to Flash Controller: STOP sending data if we cross threshold
    assign buffer_full = (fifo_count >= FULL_THRESHOLD);

    // -------------------------------------------------------------------------
    // 2. Memory Arbiter (The Magic Part)
    // -------------------------------------------------------------------------
    // We prioritize the Display Read.
    // If Display asks for data, we give address = rd_ptr.
    // Otherwise, we give address = wr_ptr.
    
    always_comb begin
        spram_cs    = 1'b1; // Always enabled
        spram_wdata = flash_data_in;
        
        if (display_req) begin
            // READING (Priority)
            spram_addr = {4'b0000, rd_ptr}; // Pad to 14 bits
            spram_wren = 1'b0;              // Read mode
        end else if (flash_write_en && !buffer_full) begin
            // WRITING (If Display is idle)
            spram_addr = {4'b0000, wr_ptr}; 
            spram_wren = 1'b1;              // Write mode
        end else begin
            // IDLE
            spram_addr = 0;
            spram_wren = 0;
            spram_cs   = 0;
        end
    end

    // -------------------------------------------------------------------------
    // 3. SPRAM Instantiation
    // -------------------------------------------------------------------------
    SB_SPRAM256KA spram_inst (
        .ADDRESS    (spram_addr),
        .DATAIN     (spram_wdata),
        .MASKWREN   (4'b1111),
        .WREN       (spram_wren),
        .CHIPSELECT (spram_cs),
        .CLOCK      (clk),
        .STANDBY    (1'b0),
        .SLEEP      (1'b0),
        .POWEROFF   (1'b0),
        .DATAOUT    (spram_rdata)
    );

    // -------------------------------------------------------------------------
    // 4. Output Logic
    // -------------------------------------------------------------------------
    // SPRAM has 1 cycle latency.
    // If you request at T0, data arrives at T1.
    assign display_data_out = spram_rdata;

endmodule