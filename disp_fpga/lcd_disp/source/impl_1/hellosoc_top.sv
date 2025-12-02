// Wava Chan
// Nov 2025
// top module for the display
// using https://github.com/thekroko/ili9341_fpga/blob/master/hellosoc_top.sv 

module hellosoc_top(
	input reset,
	input tft_sdo, output wire tft_sck, output wire tft_sdi, 
	output wire tft_dc, output wire tft_reset, output wire tft_cs,
	
	// flash data
	input logic flash_miso,
	output logic flash_mosi, output logic flash_sclk, output logic flash_cs_n,
	
	input logic[3:0] image);



	//Create clock 
	logic int_osc; // internal clock
	logic [20:0] counter;

	// Internal high-speed oscillator
	HSOSC #(.CLKHF_DIV(2'b00)) //48MHz
		hf_osc (.CLKHFPU(1'b1), .CLKHFEN(1'b1), .CLKHF(int_osc));

	// Counter 
	always_ff @(posedge int_osc) begin  
		counter <= counter + 20'd3; //operates at ~137Hz. you could get closer to 120Hz by changing to 21'd5 but this is close enough
	end
	logic tft_clk = counter[20]; //TODO: i do not know at what rate this is supposed to be at. maybe 100MHz? but we can't do that
	
	logic [15:0] currentPixel;

	// ************************ Address Manager
	logic [23:0] imageAddress;
	logic addr_done;
	addr_manager am(
		.clk(int_osc),
		.start(1'b1), //always start TODO: is this true?
		.reset(reset),
		.image(image),
		.done(addr_done),
		.addr(imageAddress)
	);

	// *************************** Flash Reader
	logic [15:0] flash_data;
	logic data_valid, buffer_full;
	flash_reader fr(
   		.clk(int_osc),            // System Clock (e.g., 48MHz)
    	.reset(reset),
    	.start_read(addr_done),     // Trigger from system to begin load
    	.buffer_full(buffer_full),    // From SPRAM FIFO (Pause signal)
    	.START_ADDRESS(imageAddress), // 24-bit start address in flash TODO: how big is this address??

    // W25Q32JV Interface
    	.flash_cs_n(flash_cs_n),     // Chip Select (Active Low)
    	.flash_sclk(flash_sclk),     // Serial Clock
    	.flash_mosi(flash_mosi),     // Master Out Slave In
    	.flash_miso(flash_miso),     // Master In Slave Out
    
    // Output to SPRAM Line Buffer
    	.flash_data_out(flash_data), // 16-bit pixel data
    	.data_valid_out(data_valid)  // Pulse high when 16 bits are ready
);

	// *************************** Video Line Buffer

	video_line_buffer vlb(
    	.clk(int_osc),            // System Clock (e.g., 48MHz)
    	.reset(reset),
		.flash_data_in(flash_data),  // 16-bit pixel from Flash
    	.flash_write_en(data_valid), // Valid signal from Flash
    	.buffer_full(buffer_full),    // Tell Flash to PAUSE if high. output

    // Interface to Display Driver (The Reader)
    	.display_req(),    // Display wants a pixel. input
    	.display_data_out(currentPixel) // Pixel to Display
	);



	// *************************** Framebuffer
	//TODO: i think we have to rework this somehow...
	reg[16:0] framebufferIndex = 17'd0;
	wire fbClk;
	
	initial framebufferIndex = 17'd0;
	
	always @ (posedge fbClk) begin
		framebufferIndex <= (framebufferIndex + 1'b1) % 17'(320*240);
	end
	
	// X,Y calc
	wire[8:0] x = 9'(framebufferIndex / 240);
	wire[7:0] y = 8'(framebufferIndex % 240);
	
	//Redefine currentPixel to show a gradient
	//wire[15:0] currentPixel = {x[8:3], x[8:3], y[7:2], y[7:2], 4'b0000};
	// *************************** TFT Module
	tft_ili9341 #(.INPUT_CLK_MHZ(100)) tft(tft_clk, tft_sdo, tft_sck, tft_sdi, tft_dc, tft_reset, tft_cs, currentPixel, fbClk);

endmodule


//My Questions
/*
How do I access the FLASH lines? Do i need to jump something on the board??? https://upduino.readthedocs.io/en/latest/tutorials/qspi_flash.html?highlight=spi%20flash

*/