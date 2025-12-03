// Wava Chan
// Nov 2025
// Driver for the WH2002AE-1 LCD


//////////////////////////////////
///////   ATTEMPT 1   ////////////
//////////////////////////////////


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
        WRITE_SCREEN,            // normal operation - write characters
        WRITE_PULSE_EN,          // pulse enable high
        WRITE_PULSE_LOW,         // pulse enable low
        WRITE_WAIT               // wait for LCD to process
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
    logic pending_screen_change;
    
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
                else next_state <= WRITE_PULSE_EN;
            end
            WRITE_PULSE_EN: begin
                if (delay_counter == 21'b0) next_state <= WRITE_PULSE_LOW;
                else next_state <= state;
            end
            WRITE_PULSE_LOW: begin
                next_state <= WRITE_WAIT;
            end
            WRITE_WAIT: begin
                if (delay_counter == 21'b0) next_state <= WRITE_SCREEN;
                else next_state <= state;
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
            char_counter <= 8'h00;
            prev_screen <= screen;
            pending_screen_change <= 1'b0;
        end
        else begin
            // Track screen change
            if (screen != prev_screen) begin
                pending_screen_change <= 1'b1;
            end
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
                    delay_counter <= 21'd1; // 1 cycle pulse width
                    if (pending_screen_change) begin
                        char_counter <= 8'h00; // reset to first character
                        pending_screen_change <= 1'b0;
                        prev_screen <= screen;
                    end else if (valid && char_counter < 8'h13) begin
                        char_counter <= char_counter + 8'b01; // next character
                    end
                end
                WRITE_PULSE_EN: begin
                    en <= 1'b1; // enable goes high
                    if (delay_counter != 21'b0) delay_counter <= delay_counter - 1'b1;
                end
                WRITE_PULSE_LOW: begin
                    en <= 1'b0; // enable goes low
                    delay_counter <= 21'd1; // wait a cycle before returning to WRITE_SCREEN
                end
                WRITE_WAIT: if (delay_counter != 21'b0) delay_counter <= delay_counter - 1'b1;
            endcase
        end
    end
endmodule
 

//////////////////////////////////
///////   ATTEMPT 2   ////////////
//////////////////////////////////

/*

module lcd_driver #(
    parameter CLK_FREQ   = 12000000, // Standard iCEstick/IceBreaker freq
    parameter NUM_CHARS  = 20,       // Set to 20 for 1 line, 40 for 2 lines
    parameter USE_CLEAR  = 0         // 1 = Clear screen (2ms) before writing. 0 = Overwrite.
)(
    input  logic       clk,
    input  logic       reset,
    input  logic       update,        // Pulse high to trigger screen update
    input  logic [7:0] screen_select, // Which message to show
    
    // Hardware Interface
    output logic [7:0] DB,
    output logic       rs, // 0=Cmd, 1=Data
    output logic       rw, // 0=Write, 1=Read
    output logic       en, // Enable Pulse
    output logic       busy // High while updating
);

    // ---------------------------------------------------------
    // 1. Timing Constants
    // ---------------------------------------------------------
    localparam int WAIT_15MS   = CLK_FREQ * 15 / 1000;
    localparam int WAIT_2MS    = CLK_FREQ * 2 / 1000;
    localparam int WAIT_50US   = CLK_FREQ * 50 / 1000000;
    localparam int PULSE_WIDTH = CLK_FREQ * 1 / 1000000; // 1us pulse

    // ---------------------------------------------------------
    // 2. State Definitions
    // ---------------------------------------------------------
    typedef enum logic [5:0] {
        S_POWER_ON,
        S_INIT_FUNC1,      // first 0x38 command
        S_INIT_WAIT1,      // wait after FUNC1
        S_INIT_FUNC2,      // second 0x38 command
        S_INIT_WAIT2,      // wait after FUNC2
        S_INIT_FUNC3,      // third 0x38 command
        S_INIT_WAIT3,      // wait after FUNC3
        S_INIT_DISPLAY_OFF,
        S_INIT_CLEAR,
        S_INIT_ENTRY,
        S_INIT_ON,
        
        S_IDLE,            // Waiting for 'update' flag
        S_PRE_CLEAR,       // Optional: Clear screen before write
        S_SET_CURSOR,      // Reset cursor to 0x00
        
        S_READ_RAM,        // Fetch char
        S_PROCESS_CHAR,    // Handle Line Breaks
        
        S_SEND_BYTE_SETUP, // Set RS/DB
        S_SEND_BYTE_PULSE, // EN High
        S_SEND_BYTE_HOLD,  // EN Low
        S_SEND_BYTE_WAIT   // Busy wait
    } state_t;

    state_t state;
    
    // ---------------------------------------------------------
    // 3. Internal Signals
    // ---------------------------------------------------------
    logic [31:0] delay_counter;
    logic [7:0]  char_cnt;
    logic [7:0]  current_data;
    logic        is_data_cmd;   
    
    // Latch the screen selection when update signal comes in
    logic [7:0]  active_screen_idx;

    // Message Handler Interface
    logic [7:0] ram_data_out;
    logic       ram_valid;
    
    // Assumes message_handler is in your project
    message_handler msg_mem (
        .clk(clk),
        .msg_index(active_screen_idx),
        .char_index(char_cnt),
        .data_out(ram_data_out),
        .valid_out(ram_valid)
    );

    assign busy = (state != S_IDLE);

    // ---------------------------------------------------------
    // 4. Main State Machine
    // ---------------------------------------------------------
    always_ff @(posedge clk) begin
        if (reset) begin
            state         <= S_POWER_ON;
            delay_counter <= WAIT_15MS;
            en            <= 0;
            rs            <= 0;
            rw            <= 0;
            DB            <= 0;
            char_cnt      <= 0;
            active_screen_idx <= 0;
        end else begin
            
            // Default: Write mode
            rw <= 0; 

            case (state)
                // --- Power On & Init ---
                S_POWER_ON: begin
                    if (delay_counter == 0) begin
                        // Directly jump to Function Set for brevity in this example
                        // (Real hardware might prefer the full 3-step wake up)
                        current_data <= 8'h38; is_data_cmd <= 0; state <= S_SEND_BYTE_SETUP;
                    end else delay_counter <= delay_counter - 1;
                end
                
                // Note: The S_SEND_BYTE logic will return to:
                // S_INIT_DISPLAY_OFF -> S_INIT_CLEAR -> S_INIT_ENTRY -> S_INIT_ON -> S_IDLE
                
                // --- Idle / Trigger ---
                S_IDLE: begin
                    if (update) begin
                        active_screen_idx <= screen_select; // Latch input
                        if (USE_CLEAR) 
                            state <= S_PRE_CLEAR;
                        else 
                            state <= S_SET_CURSOR;
                    end
                end

                // --- Update Sequence ---
                S_PRE_CLEAR: begin
                    current_data <= 8'h01; is_data_cmd <= 0; state <= S_SEND_BYTE_SETUP;
                end

                S_SET_CURSOR: begin
                    // Force cursor to 0x00 (Line 1 start)
                    current_data <= 8'h80; is_data_cmd <= 0; state <= S_SEND_BYTE_SETUP;
                end

                S_READ_RAM: begin
                    state <= S_PROCESS_CHAR; // Wait 1 cycle for RAM
                end

                S_PROCESS_CHAR: begin
                    // Stop if we hit the limit (e.g., 20)
                    if (char_cnt >= NUM_CHARS) begin
                        char_cnt <= 0;
                        state    <= S_IDLE;
                    end 
                    // Handle the 20x2 LCD Gap (Line 1 ends at 19, Line 2 starts at 0x40)
                    // Only trigger this if we are actually writing enough chars to reach line 2
                    else if (char_cnt == 20 && NUM_CHARS > 20) begin
                        current_data <= 8'hC0; // Go to Line 2 (0x40 address)
                        is_data_cmd  <= 0;     // Command
                        state        <= S_SEND_BYTE_SETUP;
                    end 
                    // Normal Character
                    else begin
                        current_data <= ram_data_out;
                        is_data_cmd  <= 1;     // Data
                        state        <= S_SEND_BYTE_SETUP;
                    end
                end

                // --- Low Level Sender ---
                S_SEND_BYTE_SETUP: begin
                    DB <= current_data;
                    rs <= is_data_cmd;
                    delay_counter <= PULSE_WIDTH;
                    state <= S_SEND_BYTE_PULSE;
                end

                S_SEND_BYTE_PULSE: begin
                    en <= 1; 
                    if (delay_counter == 0) state <= S_SEND_BYTE_HOLD;
                    else delay_counter <= delay_counter - 1;
                end

                S_SEND_BYTE_HOLD: begin
                    en <= 0; 
                    // Wait 2ms for Clear, 50us for others
                    if (is_data_cmd == 0 && (current_data == 8'h01)) 
                        delay_counter <= WAIT_2MS;
                    else 
                        delay_counter <= WAIT_50US;
                    state <= S_SEND_BYTE_WAIT;
                end

                S_SEND_BYTE_WAIT: begin
                    if (delay_counter == 0) begin
                        // Routing Logic: Where do we go after sending a byte?
                        
                        // 1. Initialization Routing
                        if (current_data == 8'h38) state <= S_INIT_DISPLAY_OFF;
                        else if (current_data == 8'h08) state <= S_INIT_CLEAR;
                        else if (current_data == 8'h01 && state != S_IDLE && state != S_PRE_CLEAR) state <= S_INIT_ENTRY;
                        else if (current_data == 8'h06) state <= S_INIT_ON;
                        else if (current_data == 8'h0C) state <= S_IDLE;
                        
                        // 2. Update Routing
                        else if (current_data == 8'h01) state <= S_SET_CURSOR; // From S_PRE_CLEAR
                        else if (current_data == 8'h80) begin char_cnt <= 0; state <= S_READ_RAM; end // From S_SET_CURSOR
                        else if (current_data == 8'hC0) state <= S_READ_RAM;   // From Gap Jump (don't inc counter)
                        
                        // 3. Character written
                        else begin 
                             char_cnt <= char_cnt + 1;
                             state    <= S_READ_RAM;
                        end
                    end else delay_counter <= delay_counter - 1;
                end
            endcase
        end
    end

endmodule

*/