// Testbench for LCD Driver module
// Tests initialization sequence and message writing

`timescale 1ns / 1ps

module lcd_driver_tb();
    
    // Signals
    logic [3:0] screen;
    logic reset;
    logic change_screen;
    logic [7:0] DB;
    logic rs;
    logic rw;
    logic en;
    logic clk; 

    // generate clk

    always 
		begin 
			clk = 1; #5; clk = 0; #5;
		end
    
    // Internal test signals
    integer test_cycle = 0;
    
    // Instantiate DUT
    lcd_driver dut (
        .clk(clk),
        .screen(screen),
        .reset(reset),
        .change_screen(change_screen),
        .DB(DB),
        .rs(rs),
        .rw(rw),
        .en(en)
    );
    
    // Task to display LCD command/data on EN pulse
    task display_lcd_command();
        // Check for rising edge of EN (pulse high)
        if (en && dut.state == dut.WRITE_PULSE_EN) begin
            if (rs == 0 && rw == 0) begin
                case (DB)
                    8'h38: $display("[%0t] CMD: Function Set (0x38)", $time);
                    8'h08: $display("[%0t] CMD: Display Off (0x08)", $time);
                    8'h01: $display("[%0t] CMD: Clear Display (0x01)", $time);
                    8'h06: $display("[%0t] CMD: Entry Mode (0x06)", $time);
                    8'h0C: $display("[%0t] CMD: Display On (0x0C)", $time);
                    default: $display("[%0t] CMD: Unknown (0x%02X)", $time, DB);
                endcase
            end else if (rs == 1 && rw == 0) begin
                if (DB >= 32 && DB < 127) begin
                    $display("[%0t] DATA: '%c' (0x%02X) from messages[%d][%d]", $time, DB, DB, screen, dut.char_counter);
                end else begin
                    $display("[%0t] DATA: 0x%02X from messages[%d][%d]", $time, DB, screen, dut.char_counter);
                end
            end
        end
    endtask
    
    // Main test procedure
    initial begin
        // Initialize
        screen = 4'h0;
        reset = 1'b1;
        change_screen = 1'b0;
        
        $display("=== LCD Driver Testbench ===");
        $display("Starting at time %0t ns", $time);
        
        // Reset for 100 cycles
        #100;
        reset = 1'b0;
        $display("\n=== Reset released at %0t ns ===", $time);
        
        // Wait for initialization sequence to complete
        // Initialization now includes pulse states for each command
        
        $display("\n=== Waiting for initialization sequence ===");
        wait(dut.state == dut.WRITE_SCREEN);
        $display("Initialization complete at %0t ns", $time);
        
        #100;
        
        // Test 1: Display message 0
        $display("\n=== Test 1: Display Message 0 ===");
        screen = 4'h0;
        
        // Wait a few cycles to see character writes
        repeat(100) begin
            #10;
            display_lcd_command();
        end
        
        #100;
        
        // Test 2: Switch to message 1
        $display("\n=== Test 2: Switch to Message 1 ===");
        screen = 4'h1;
        
        // Wait for screen change to trigger DISPLAY_CLEAR
        wait(dut.state == dut.DISPLAY_CLEAR);
        $display("Screen change detected, entering DISPLAY_CLEAR state");
        
        // Wait for display to reinitialize and write new message
        wait(dut.state == dut.WRITE_SCREEN);
        $display("Back to WRITE_SCREEN state");
        
        repeat(100) begin
            #10;
            display_lcd_command();
        end
        
        #100;
        
        // Test 3: Switch to message 3
        $display("\n=== Test 3: Switch to Message 3 ===");
        screen = 4'h3;
        
        wait(dut.state == dut.DISPLAY_CLEAR);
        wait(dut.state == dut.WRITE_SCREEN);
        
        repeat(100) begin
            #10;
            display_lcd_command();
        end
        
        #100;
        
        // Test 4: Rapid message switching
        $display("\n=== Test 4: Rapid Message Switching ===");
        for (int i = 0; i < 5; i++) begin
            screen = i;
            $display("Switching to message %d", i);
            repeat(50) #10;
        end
        
        #200;
        $display("\n=== Test Complete ===");
        $finish;
    end
    
    // Monitor for state changes and EN pulses
    initial begin
        forever begin
            @(posedge clk);
            if (dut.state == dut.WRITE_PULSE_EN && en) begin
                $display("[%0t] EN PULSE: State=%s, RS=%b, DB=0x%02X", 
                         $time, dut.state.name(), rs, DB);
            end
            if (dut.state != dut.state'($past(dut.state))) begin
                $display("[%0t] STATE CHANGE: %s -> %s", 
                         $time, $past(dut.state).name(), dut.state.name());
            end
        end
    end


endmodule
