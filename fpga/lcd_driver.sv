// Wava Chan
// Nov 2025
// Driver for the WH2002AE-1 LCD

module lcd_driver(
	input logic clk,
    input logic [7:0] screen,
    input logic reset,
    input logic change_screen,
    output logic [7:0] DB, //data bus
    output logic rs,
    output logic rw, //read/write. high = read, low = write
    output logic en // chip enable
    );

    // set up internal logic 
    typedef enum {
        START,                    // power-on reset
        POWER_ON_WAIT,           // wait 15ms after power-on
        INIT_FUNCTION_SET_1,     // first 0x38 command
        INIT_WAIT_1,             // wait ~4.1ms
        INIT_FUNCTION_SET_2,     // second 0x38 command
        INIT_WAIT_2,             // wait ~100us
        INIT_FUNCTION_SET_3,     // third 0x38 command
        INIT_WAIT_3,             // wait ~100us
        DISPLAY_OFF,             // send 0x08
        DISPLAY_OFF_WAIT,        // wait ~100us
        DISPLAY_CLEAR,           // send 0x01
        DISPLAY_CLEAR_WAIT,      // wait ~1.6ms for clear to complete
        ENTRY_MODE,              // send 0x06 (auto-increment, no shift)
        ENTRY_MODE_WAIT,         // wait ~100us
        DISPLAY_ON,              // send 0x0C (display on, cursor off, no blink)
        DISPLAY_ON_WAIT,         // wait ~100us
        WRITE_SCREEN             // normal operation - write characters
    } state_t;

    state_t state, next_state;
    
    // Timing counter for delays (only used within WAIT states)
    logic [20:0] delay_counter;
    
    // write display data to storage
    logic [7:0] msg_index, char_index, data; // character in message?
    logic valid;
    
    // Character counter for writing to display
    logic [7:0] char_counter;
    
    messages mes( //essentially a wrapper for the EBR_DP block
        .clk(clk), 
        .msg_index(screen), // use input screen signal directly for message selection
        .char_index(char_counter), // use internal character counter
        .data_out(data), // actual data. to be written to screen
        .valid_out(valid)
    );
    

    // state machine
    always_ff @(posedge clk) begin
        if (reset) begin
            state <= START;
        end
        else begin
            state <= next_state;
        end 
    end

    // Track if screen changed to reset character counter
    logic [3:0] prev_screen;
    always_ff @(posedge clk) begin
        prev_screen <= screen;
    end
    
    // state transitions
    always_comb begin
        next_state <= state; // default: hold state
        case (state)
            START: begin
                next_state <= POWER_ON_WAIT;
            end
            POWER_ON_WAIT: begin 
                if (delay_counter == 21'b0) next_state <= INIT_FUNCTION_SET_1;
				else next_state <= state; // stay the same otherwise
            end
            INIT_FUNCTION_SET_1: begin
                if (delay_counter == 21'b0) next_state <= INIT_WAIT_1;
				else next_state <= state;
            end
            INIT_WAIT_1: begin
                if (delay_counter == 21'b0) next_state <= INIT_FUNCTION_SET_2;
				else next_state <= state;
            end
            INIT_FUNCTION_SET_2: begin
                if (delay_counter == 21'b0) next_state <= INIT_WAIT_2;
				else next_state <= state;
            end
            INIT_WAIT_2: begin
                if (delay_counter == 21'b0) next_state <= INIT_FUNCTION_SET_3;
				else next_state <= state;
            end
            INIT_FUNCTION_SET_3: begin
                if (delay_counter == 21'b0) next_state <= INIT_WAIT_3;
				else next_state <= state;
            end
            INIT_WAIT_3: begin
                if (delay_counter == 21'b0) next_state <= DISPLAY_OFF;
				else next_state <= state;
            end
            DISPLAY_OFF: begin
                if (delay_counter == 21'b0) next_state <= DISPLAY_OFF_WAIT;
				else next_state <= state;
            end
            DISPLAY_OFF_WAIT: begin
                if (delay_counter == 21'b0) next_state <= DISPLAY_CLEAR;
				else next_state <= state;
            end
            DISPLAY_CLEAR: begin
                if (delay_counter == 21'b0) next_state <= DISPLAY_CLEAR_WAIT;
				else next_state <= state;
            end
            DISPLAY_CLEAR_WAIT: begin
                if (delay_counter == 21'b0) next_state <= ENTRY_MODE;
				else next_state <= state;
            end
            ENTRY_MODE: begin
                if (delay_counter == 21'b0) next_state <= ENTRY_MODE_WAIT;
				else next_state <= state;
            end
            ENTRY_MODE_WAIT: begin
                if (delay_counter == 21'b0) next_state <= DISPLAY_ON;
				else next_state <= state;
            end
            DISPLAY_ON: begin
                if (delay_counter == 21'b0) next_state <= DISPLAY_ON_WAIT;
				else next_state <= state;
            end
            DISPLAY_ON_WAIT: begin
                if (delay_counter == 21'b0) next_state <= WRITE_SCREEN;
				else next_state <= state;
            end
            WRITE_SCREEN: begin
                if (screen != prev_screen) next_state <= DISPLAY_CLEAR;
                else next_state <= WRITE_SCREEN;
            end
            default: next_state <= START;
        endcase
    end
    
    // Output logic - set commands and control signals
    always_ff @(posedge clk) begin
        if (reset) begin
            rs <= 1'b0;
            rw <= 1'b0;
            DB <= 8'h00;
            en <= 1'b0;
            delay_counter <= 21'b0;
        end
        else begin
            en <= 1'b0; // default: disable
            case(state)
                START: begin
                    rs <= 1'b0;
                    rw <= 1'b0;
                    DB <= 8'h00;
                    delay_counter <= 21'd2; // 15ms delay, ~2 cycles
                end
                POWER_ON_WAIT: begin
                    // Decrement delay counter
                    if (delay_counter != 21'b0) delay_counter <= delay_counter - 1'b1;
                end
            INIT_FUNCTION_SET_1, INIT_FUNCTION_SET_2, INIT_FUNCTION_SET_3: begin
                rs <= 1'b0; // command mode
                rw <= 1'b0; // write
                DB <= 8'b00111000; // 0x38: 8-bit, 2-line, 5x8 font
                en <= 1'b1;
                delay_counter <= 21'd2; // 1 cycle for enable hold + 1 for safety = ~15ms total
            end
            INIT_WAIT_1: if (delay_counter != 21'b0) delay_counter <= delay_counter - 1'b1;
            INIT_WAIT_2: if (delay_counter != 21'b0) delay_counter <= delay_counter - 1'b1;
            INIT_WAIT_3: if (delay_counter != 21'b0) delay_counter <= delay_counter - 1'b1;
                DISPLAY_OFF: begin
                    rs <= 1'b0;
                    rw <= 1'b0;
                    DB <= 8'b00001000; // 0x08: display off
                    en <= 1'b1;
                    delay_counter <= 21'd1;
                end
                DISPLAY_OFF_WAIT: if (delay_counter != 21'b0) delay_counter <= delay_counter - 1'b1;
                DISPLAY_CLEAR: begin
                    rs <= 1'b0;
                    rw <= 1'b0;
                    DB <= 8'b00000001; // 0x01: clear display
                    en <= 1'b1;
                    delay_counter <= 21'd1; // ~1.6ms for clear
                end
                DISPLAY_CLEAR_WAIT: if (delay_counter != 21'b0) delay_counter <= delay_counter - 1'b1;
                ENTRY_MODE: begin
                    rs <= 1'b0;
                    rw <= 1'b0;
                    DB <= 8'b00000110; // 0x06: increment, no shift
                    en <= 1'b1;
                    delay_counter <= 21'd1;
                end
                ENTRY_MODE_WAIT: if (delay_counter != 21'b0) delay_counter <= delay_counter - 1'b1;
                DISPLAY_ON: begin
                    rs <= 1'b0;
                    rw <= 1'b0;
                    DB <= 8'b00001100; // 0x0C: display on, cursor off, no blink
                    en <= 1'b1;
                    delay_counter <= 21'd1;
                end
                DISPLAY_ON_WAIT: if (delay_counter != 21'b0) delay_counter <= delay_counter - 1'b1;
                WRITE_SCREEN: begin
                    rs <= 1'b1; // data mode
                    rw <= 1'b0; // write
                    DB <= data; // from messages ROM
                    en <= 1'b1;
                    
                    // Increment character counter when screen changes
                    if (screen != prev_screen) begin
                        char_counter <= 8'h00; // reset to first character
                    end
                    else if (valid && char_counter < 8'hFF) begin
                        char_counter <= char_counter + 8'h01; // next character
                    end
                end
            endcase
        end
    end
endmodule