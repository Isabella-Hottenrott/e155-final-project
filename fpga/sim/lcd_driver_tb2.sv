`timescale 1ns / 1ps

module lcd_driver_tb;

    // Parameters
    // Speed up simulation by using a fake fast clock frequency
    // or small delay values. Here we use real freq but small wait checks.
    localparam CLK_FREQ = 12000000; 

    // DUT Signals
    logic       clk;
    logic       reset;
    logic       update;
    logic [7:0] screen_select;
    
    logic [7:0] DB;
    logic       rs;
    logic       rw;
    logic       en;
    logic       busy;

    // Instantiate DUT (Device Under Test)
    lcd_driver #(
        .CLK_FREQ(CLK_FREQ),
        .NUM_CHARS(20), // Testing 20 char mode
        .USE_CLEAR(0)
    ) dut (
        .clk(clk),
        .reset(reset),
        .update(update),
        .screen_select(screen_select),
        .DB(DB),
        .rs(rs),
        .rw(rw),
        .en(en),
        .busy(busy)
    );

    // Clock Generation (12MHz)
    initial begin
        clk = 0;
        forever #41.66 clk = ~clk; // ~83.33ns period
    end

    // Test Sequence
    initial begin
        // 1. Initialize
        reset = 1;
        update = 0;
        screen_select = 8'h00;
        
        // Wait for a few clocks then release reset
        #100;
        reset = 0;
        
        $display("--- Simulation Start ---");
        $display("Waiting for Power-On Initialization...");

        // 2. Wait for Busy to go low (Init complete)
        // In real sim this takes 15ms+ which is forever. 
        // We will force wait a bit, then assume init is done for waveform viewing
        // or we rely on the busy flag.
        wait(!busy);
        $display("Initialization Complete at %t", $time);

        // 3. Trigger a Screen Update (Screen 1)
        #1000;
        $display("Triggering Screen 1 Update...");
        screen_select = 8'h01;
        update = 1;
        #100; // Hold pulse
        update = 0;
        
        // Wait for processing
        wait(busy); 
        wait(!busy);
        $display("Screen 1 Update Complete at %t", $time);

        // 4. Trigger Screen Update (Screen 2)
        #1000;
        $display("Triggering Screen 2 Update...");
        screen_select = 8'h02;
        update = 1;
        #100;
        update = 0;
        
        wait(!busy);
        $display("Screen 2 Update Complete at %t", $time);
        
        #2000;
        $finish;
    end
    
    // Monitor to print what's happening on the pins
    always @(negedge en) begin
        if (reset == 0) begin
            if (rs == 0)
                $display("LCD CMD: 0x%h at %t", DB, $time);
            else
                $display("LCD DATA: '%c' (0x%h) at %t", DB, DB, $time);
        end
    end

endmodule

// ---------------------------------------------------------
// DUMMY MESSAGE HANDLER FOR SIMULATION
// ---------------------------------------------------------
// This overrides the real IP block instantiation in the DUT
// if you compile both files together.
module message_handler (
    input  logic        clk,
    input  logic [7:0]  msg_index,
    input  logic [7:0]  char_index,
    output logic [7:0]  data_out,
    output logic        valid_out
);
    // Simple mock data generator
    // Returns 'A' + char_index for any message
    always_comb begin
        if (msg_index == 1) 
            data_out = 8'h41 + char_index; // A, B, C...
        else if (msg_index == 2)
            data_out = 8'h61 + char_index; // a, b, c...
        else 
            data_out = 8'h30 + char_index; // 0, 1, 2...
            
        valid_out = 1'b1;
    end

endmodule