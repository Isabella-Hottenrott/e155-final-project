// Testbench for messages ROM module
// Tests reading characters from different messages

`timescale 1ns / 1ps

module messages_tb();
    
    // Signals
    logic clk;
    logic [7:0] msg_index;
    logic [7:0] char_index;
    logic [7:0] data;
    logic valid;
    
    // Instantiate DUT
    messages dut (
        .clk(clk),
        .msg_index(msg_index),
        .char_index(char_index),
        .data_out(data),
        .valid_out(valid)
    );
    
    // Clock generation
    always 
		begin 
			clk = 1; #5; clk = 0; #5;
		end
    // Test procedure
    initial begin


        // Initialize
        msg_index = 3'h00;
        char_index = 8'h00;
        
        #20; // Wait for initial pipeline latency (2 cycles)
        
        // Test 1: Read message 0 "Rock" sequentially
        $display("=== Test 1: Reading Message 0 (Rock) ===");
        for (int i = 0; i < 20; i++) begin
            char_index = i;
            #10; // Wait one cycle for latency
            $display("char_index=%d, data=0x%02X (%c)", i, data, data);//(data >= 32 && data < 127) ? data : '?');
        end
        
        #20; // Gap between messages
        
        // Test 2: Read message 1 "Paper" sequentially
        $display("\n=== Test 2: Reading Message 1 (Paper) ===");
        msg_index =  3'h01;
        for (int i = 0; i < 20; i++) begin
            char_index = i;
            #10;
            $display("char_index=%d, data=0x%02X ('%c')", i, data, data); //(data >= 32 && data < 127) ? data : '?');
        end
        
        #20;
        
        // Test 3: Read message 2 "Scissors" sequentially
        $display("\n=== Test 3: Reading Message 2 (Scissors) ===");
        msg_index = 3'h02;
        for (int i = 0; i < 20; i++) begin
            char_index = i;
            #10;
            $display("char_index=%d, data=0x%02X ('%c')", i, data, data); //(data >= 32 && data < 127) ? data : '?');
        end
        
        #20;
        
        // Test 4: Test message switching with same char_index
        $display("\n=== Test 4: Switching Messages ===");
        msg_index = 3'h03; // "You Win!"
        char_index = 8'h01;
        #10;
        $display("Message 3, char 0: 0x%02X ('%c')", data, data); //(data >= 32 && data < 127) ? data : '?');
        
        msg_index = 8'h04; // "You Lose!"
        #10;
        $display("Message 4, char 0: 0x%02X ('%c')", data, data); //(data >= 32 && data < 127) ? data : '?');
        
        msg_index = 8'h05; // "Tie"
        #10;
        $display("Message 5, char 0: 0x%02X ('%c')", data, data); //(data >= 32 && data < 127) ? data : '?');
        
        #20;
        
        // Test 5: Verify padding (spaces = 0x20)
        $display("\n=== Test 5: Verifying Space Padding (0x20) ===");
        msg_index = 8'h00; // "Rock" with padding
        for (int i = 4; i < 8; i++) begin
            char_index = i;
            #10;
            if (data == 8'h20) begin
                $display("char_index=%d: PASS - Got space (0x20)", i);
            end else begin
                $display("char_index=%d: FAIL - Expected 0x20, got 0x%02X", i, data);
            end
        end
        
        #20;
        
        // Test 6: Multi-row message (spanning multiple addresses)
        $display("\n=== Test 6: Multi-row Message (You Win!) ===");
        msg_index = 8'h03;
        for (int i = 0; i < 8; i++) begin
            char_index = i;
            #20;
            $display("char_index=%d, data=0x%02X ('%c')", i, data, data); //(data >= 32 && data < 127) ? data : '?');
        end
        
        #50;
        $finish;
    end

endmodule
