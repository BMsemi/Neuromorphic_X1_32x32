`timescale 1ns/1ps

module Neuromorphic_X1_wb_tb;

  // Clock and reset signals
  reg user_clk;
  reg user_rst;
  reg wb_clk_i;
  reg wb_rst_i;

  // Wishbone interface signals
  reg wbs_stb_i;
  reg wbs_cyc_i;
  reg wbs_we_i;
  reg [3:0] wbs_sel_i;
  reg [31:0] wbs_dat_i;
  reg [31:0] wbs_adr_i;
  wire [31:0] wbs_dat_o;
  wire wbs_ack_o;
	
	reg [31:0] rdata;
	
	localparam [31:0] ADDR_MATCH = 32'h3000_000C;

  // Instantiate the design under test (DUT)
  Neuromorphic_X1_wb dut (
    .user_clk(user_clk),
    .user_rst(user_rst),
    .wb_clk_i(wb_clk_i),
    .wb_rst_i(wb_rst_i),
    .wbs_stb_i(wbs_stb_i),
    .wbs_cyc_i(wbs_cyc_i),
    .wbs_we_i(wbs_we_i),
    .wbs_sel_i(wbs_sel_i),
    .wbs_dat_i(wbs_dat_i),
    .wbs_adr_i(wbs_adr_i),
    .wbs_dat_o(wbs_dat_o),
    .wbs_ack_o(wbs_ack_o)
  );
	
	// ========= Helpers =========
  function [31:0] pack_cmd;
    input [1:0]  mode;
    input [4:0]  row;
    input [4:0]  col;
    input [19:0] data20;
    begin
      pack_cmd = {mode, row, col, data20};
    end
  endfunction
	
	task wb_write32(input [31:0] addr, input [31:0] data);
    begin
      @(posedge wb_clk_i);
      wbs_adr_i <= addr;
      wbs_dat_i <= data;
      wbs_sel_i <= 4'hF;
      wbs_we_i  <= 1'b1;
      wbs_cyc_i <= 1'b1;
      wbs_stb_i <= 1'b1;
      // wait for ack
      wait(wbs_ack_o);
			@(posedge wb_clk_i);
      wbs_cyc_i <= 1'b0;
      wbs_stb_i <= 1'b0;
      wbs_we_i  <= 1'b0;
      wbs_sel_i <= 4'h0;
      wbs_adr_i <= 32'd0;
      wbs_dat_i <= 32'd0;
    end
  endtask

  task wb_read32(input [31:0] addr, output [31:0] data);
    begin
      @(posedge wb_clk_i);
      wbs_adr_i <= addr;
      wbs_we_i  <= 1'b0;
      wbs_sel_i <= 4'hF;
      wbs_cyc_i <= 1'b1;
      wbs_stb_i <= 1'b1;
      // wait for ack
      wait(wbs_ack_o);
      data = wbs_dat_o;
      // drop bus
      @(posedge wb_clk_i);
      wbs_cyc_i <= 1'b0;
      wbs_stb_i <= 1'b0;
      wbs_sel_i <= 4'h0;
      wbs_adr_i <= 32'd0;
    end
  endtask

  // Clock generation
  always begin
    #10 user_clk = ~user_clk;
  end

  always begin
    #10 wb_clk_i = ~wb_clk_i; // 50 MHz Wishbone clock
  end
  
	// // ****************************************************************************************
	
	// // **** Comment From Here 1 ****
  // // Reset generation
  // initial begin
    // user_clk = 0;
    // wb_clk_i = 0;
    // user_rst = 1;
    // wb_rst_i = 1;

    // // Release reset after some time
    // #20 user_rst = 0;
    // #20 wb_rst_i = 0;
    
		// @(posedge wb_clk_i);
		
    // // Initializing Wishbone signals
    // wbs_stb_i = 0;
    // wbs_cyc_i = 0;
    // wbs_we_i = 0;
    // wbs_sel_i = 4'b1111;
    // wbs_dat_i = 32'b0;
    // wbs_adr_i = 32'h0000_0000;
    
    // wb_write32(ADDR_MATCH, pack_cmd(2'b11, 5'd1, 5'd1, 20'h0FF));
		
		// wb_write32(ADDR_MATCH, pack_cmd(2'b01, 5'd1, 5'd1, 20'h00000));
		
		// wb_read32(ADDR_MATCH, rdata);
		
		// //#5000;
		// #200;
		
		// wb_write32(ADDR_MATCH, pack_cmd(2'b11, 5'd5, 5'd4, 20'h000));
		
		// wb_write32(ADDR_MATCH, pack_cmd(2'b01, 5'd5, 5'd4, 20'h00000));
		
		// wb_read32(ADDR_MATCH, rdata1);
		// #50;
		
		// wb_write32(ADDR_MATCH, pack_cmd(2'b11, 5'd7, 5'd2, 20'h000));
		
		// wb_write32(ADDR_MATCH, pack_cmd(2'b01, 5'd7, 5'd2, 20'h00000));
		
		
		// wb_read32(ADDR_MATCH, rdata);
		
		// #200;

    // // Finish the simulation
    // $finish;
  // end
	// // **** Comment Till Here 1 ****
	
	// // ****************************************************************************************
	
	// **** Comment From Here 2 ****
	integer i;
  reg [19:0] rand_data;
	
  initial begin
    user_clk = 0;
    wb_clk_i = 0;
    user_rst = 1;
    wb_rst_i = 1;

    // Release reset after some time
    #20 user_rst = 0;
    #20 wb_rst_i = 0;
    
    @(posedge wb_clk_i);
    
    // Initializing Wishbone signals
    wbs_stb_i = 0;
    wbs_cyc_i = 0;
    wbs_we_i = 0;
    wbs_sel_i = 4'b1111;
    wbs_dat_i = 32'b0;
    wbs_adr_i = 32'h0000_0000;
    
    // Fill the FIFO by performing 32 write operations with randomized data
    for (i = 0; i < 33; i = i + 1) begin
      // Randomize data to either 20'hFF or 20'h00
      rand_data = (i % 2 == 0) ? 20'hFF : 20'h00; // Alternate between 0xFF and 0x00
      
      // Write operation with randomized data
      wb_write32(ADDR_MATCH, pack_cmd(2'b11, i[4:0], i[4:0], rand_data)); // Example randomized data
    end
		
		repeat(10) @(posedge wb_clk_i);
		
		 // Fill the FIFO by performing 32 write operations with randomized data
    for (i = 0; i < 33; i = i + 1) begin
      // Randomize data to either 20'hFF or 20'h00
      rand_data =  20'h00;
      
      // Write operation with randomized data
      wb_write32(ADDR_MATCH, pack_cmd(2'b01, i[4:0], i[4:0], rand_data)); // Example randomized data
    end

    // Finish the simulation
    #30000;
		for (i = 0; i < 33; i = i + 1) begin
		  wb_read32(ADDR_MATCH, rdata);
		end
		// for (i = 0; i < 5; i = i + 1) begin
      // // Randomize data to either 20'hFF or 20'h00
      // rand_data = (i % 2 == 0) ? 20'hFF : 20'h00; // Alternate between 0xFF and 0x00
      
      // // Write operation with randomized data
      // wb_write32(ADDR_MATCH, pack_cmd(2'b01, i[4:0], i[4:0], rand_data)); // Example randomized data
    // end
		
    $finish;
  end
	// **** Comment Till Here 2 ****
	
	// // ****************************************************************************************
	
	// // **** Comment From Here 3 ****  // Required
	// // Reset generation
  // initial begin
    // user_clk = 0;
    // wb_clk_i = 0;
    // user_rst = 1;
    // wb_rst_i = 1;

    // // Release reset after some time
    // #20 user_rst = 0;
    // #20 wb_rst_i = 0;
    
		// @(posedge wb_clk_i);
		
    // // Initializing Wishbone signals
    // wbs_stb_i = 0;
    // wbs_cyc_i = 0;
    // wbs_we_i = 0;
    // wbs_sel_i = 4'b1111;
    // wbs_dat_i = 32'b0;
    // wbs_adr_i = 32'h0000_0000;
    
    // wb_write32(ADDR_MATCH, pack_cmd(2'b11, 5'd1, 5'd1, 20'h0FF));  // Op0
		
		// wb_write32(ADDR_MATCH, pack_cmd(2'b01, 5'd1, 5'd1, 20'h00000));  // Op1
		
		// wb_read32(ADDR_MATCH, rdata);  // Op2
		// if(rdata == 32'h1) $display("1st Test Passed exp %h = act %h",32'h1,rdata);
		// else $display("1st Test Failes exp %h = act %h",32'h1,rdata);
		
		// // Op3
		// wb_write32(ADDR_MATCH, pack_cmd(2'b01, 5'd1, 5'd1, 20'h00000));  // Op1
		
		// wb_read32(ADDR_MATCH, rdata);  // Op2
		// if(rdata == 32'h1) $display("2nd Test Passed exp %h = act %h",32'h1,rdata);
		// else $display("2nd Test Failes exp %h = act %h",32'h1,rdata);
		
		
		// #1000;

    // // Finish the simulation
    // $finish;
  // end
	// // **** Comment Till Here 3 ****
	
	// // ****************************************************************************************
	
	// // **** Comment From Here 4 ****  // Required Advance
	// // Reset generation
  // initial begin
    // user_clk = 0;
    // wb_clk_i = 0;
    // user_rst = 1;
    // wb_rst_i = 1;

    // // Release reset after some time
    // #20 user_rst = 0;
    // #20 wb_rst_i = 0;
    
		// @(posedge wb_clk_i);
		
    // // Initializing Wishbone signals
    // wbs_stb_i = 0;
    // wbs_cyc_i = 0;
    // wbs_we_i = 0;
    // wbs_sel_i = 4'b1111;
    // wbs_dat_i = 32'b0;
    // wbs_adr_i = 32'h0000_0000;
    
    // wb_write32(ADDR_MATCH, pack_cmd(2'b11, 5'd1, 5'd1, 20'h0FF));  // Op0
		
		// wb_write32(ADDR_MATCH, pack_cmd(2'b01, 5'd1, 5'd1, 20'h00000));  // Op1
		// repeat(5) @(posedge wb_clk_i);
		// wb_read32(ADDR_MATCH, rdata);  // Op6
		
		// repeat(60) @(posedge wb_clk_i);
		
		// wb_read32(ADDR_MATCH, rdata);  // Op2
		// if(rdata == 32'h1) $display("1st Test Passed exp %h = act %h",32'h1,rdata);
		// else $display("1st Test Failes exp %h = act %h",32'h1,rdata);
		
		// wb_write32(ADDR_MATCH, pack_cmd(2'b11, 5'd5, 5'd4, 20'h000));  // Op3
		
		// wb_write32(ADDR_MATCH, pack_cmd(2'b01, 5'd5, 5'd4, 20'h00000));  // Op4
	
		// wb_write32(ADDR_MATCH, pack_cmd(2'b01, 5'd1, 5'd1, 20'h00000));  // Op5
		
		// #2000;
		
		// wb_read32(ADDR_MATCH, rdata);  // Op6
		// if(rdata == 32'h0) $display("2nd Test Passed exp %h = act %h",32'h0,rdata);
		// else $display("2nd Test Failes exp %h = act %h",32'h0,rdata);
		
		// wb_read32(ADDR_MATCH, rdata);  // Op7
		// if(rdata == 32'h1) $display("3rd Test Passed exp %h = act %h",32'h1,rdata);
		// else $display("3rd Test Failes exp %h = act %h",32'h1,rdata);
		
		// wb_read32(ADDR_MATCH, rdata);  // Op7
		
		// #1000;

    // // Finish the simulation
    // $finish;
  // end
	// // **** Comment Till Here 4 ****
	
	// // ****************************************************************************************
	
	
	

endmodule
