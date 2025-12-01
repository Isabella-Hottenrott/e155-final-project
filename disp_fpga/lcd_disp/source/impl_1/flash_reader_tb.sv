`timescale 1ns / 1ps

module flash_reader_tb();

    // Clock and reset
    reg clk = 0;
    reg reset = 1;

    // DUT signals
    wire flash_cs_n;
    wire flash_sclk;
    wire flash_mosi;
    reg  flash_miso = 1'b0;

    // Outputs from DUT
    wire [15:0] flash_data_out;
    wire data_valid_out;

    // Control inputs
    reg start_read = 0;
    reg buffer_full = 0;
    reg [23:0] START_ADDRESS = 24'h000000;

    // Instantiate DUT
    flash_reader dut(
        .clk(clk),
        .reset(reset),
        .start_read(start_read),
        .buffer_full(buffer_full),
        .START_ADDRESS(START_ADDRESS),
        .flash_cs_n(flash_cs_n),
        .flash_sclk(flash_sclk),
        .flash_mosi(flash_mosi),
        .flash_miso(flash_miso),
        .flash_data_out(flash_data_out),
        .data_valid_out(data_valid_out)
    );

    // Generate main clock (48 MHz approx -> period ~20.83 ns). Use 20 ns for simplicity
    always #10 clk = ~clk;

    // Simple SPI flash behavioral model to interact with DUT
    // We sample MOSI on rising edge of flash_sclk, and drive MISO on falling edge.
    reg [7:0] rx_byte = 8'h00;
    integer rx_bit_count = 0;
    integer byte_count = 0;
    reg [7:0] tx_buf [0:15]; // bytes to transmit after address/dummy
    integer tx_idx = 0;
    reg sending = 0;
    reg [7:0] tx_shift = 8'h00;
    integer tx_bit_cnt = 0;

    // Capture MOSI on rising edge of flash_sclk
    always @(posedge flash_sclk) begin
        rx_byte <= {rx_byte[6:0], flash_mosi};
        rx_bit_count <= rx_bit_count + 1;
        if (rx_bit_count == 7) begin
            // full byte received
            $display("[%0t] SPI Slave received byte %0d: 0x%02h", $time, byte_count, {rx_byte[6:0], flash_mosi});
            rx_bit_count <= 0;
            byte_count = byte_count + 1;
            // Check for command 0x0B at byte_count==0
            if (byte_count == 1) begin
                if ({rx_byte[6:0], flash_mosi} == 8'h0B) begin
                    $display("[%0t] Detected FAST_READ command", $time);
                end
            end
        end
    end

    // Drive MISO on falling edge of flash_sclk
    always @(negedge flash_sclk) begin
        if (sending) begin
            // output MSB first
            flash_miso <= tx_shift[7];
            tx_shift <= {tx_shift[6:0], 1'b0};
            tx_bit_cnt = tx_bit_cnt + 1;
            if (tx_bit_cnt == 8) begin
                // move to next byte
                tx_bit_cnt = 0;
                tx_idx = tx_idx + 1;
                if (tx_idx <= $size(tx_buf)-1) begin
                    tx_shift = tx_buf[tx_idx];
                end else begin
                    sending = 0;
                    flash_miso <= 1'bz; // tri-state (not strictly necessary in sim)
                end
            end
        end else begin
            flash_miso <= 1'b1; // idle high
        end
    end

    // Monitor DUT data_valid and display pixels
    integer pixel_count = 0;
    always @(posedge clk) begin
        if (data_valid_out) begin
            $display("[%0t] DUT produced pixel %0d: 0x%04h", $time, pixel_count, flash_data_out);
            pixel_count = pixel_count + 1;
        end
    end

    // Test sequence
    initial begin
        // Initialize tx buffer with a few sample pixel bytes (LSB then MSB order for each 16-bit word)
        // We'll provide two 16-bit pixels: 0x1234 and 0xABCD -> bytes: 0x34,0x12, 0xCD,0xAB
        tx_buf[0] = 8'h34; tx_buf[1] = 8'h12; tx_buf[2] = 8'hCD; tx_buf[3] = 8'hAB;
        // rest zero
        integer i; for (i=4;i<16;i=i+1) tx_buf[i] = 8'h00;

        // Release reset
        #50;
        reset = 0;
        #50;

        // start a read
        START_ADDRESS = 24'h000000;
        start_read = 1;
        #20;
        start_read = 0;

        // Wait for DUT to assert flash_cs_n low
        wait (flash_cs_n == 1'b0);
        $display("[%0t] flash_cs_n asserted by DUT", $time);

        // Now wait for some MOSI bytes to be sent from DUT. We'll detect the command 0x0B by monitoring byte_count.
        // After seeing the command + 3 address bytes + 1 dummy, start sending the tx_buf bytes.

        // Polling loop: wait until byte_count >= 4 (cmd + 3 addr)
        wait (byte_count >= 4);
        $display("[%0t] Received command+address (or at least 4 bytes). Now waiting for dummy byte...", $time);

        // wait for dummy byte (5th byte). Note byte_count increments after receiving each byte.
        wait (byte_count >= 5);
        $display("[%0t] Received dummy byte. Starting to send pixel data.", $time);

        // Start sending prepared data bytes
        sending = 1;
        tx_idx = 0;
        tx_shift = tx_buf[0];
        tx_bit_cnt = 0;

        // Let DUT read a few pixels
        #5000;

        $display("[%0t] Testbench finished. Pixel_count=%0d", $time, pixel_count);
        $finish;
    end

endmodule
