//--------------------------------------------------------------------------------------------------
//  ReRAM Wishbone Interface Testbench
//  This testbench simulates randomized Wishbone write and read transactions to a behavioral model 
//  of a 32x32 ReRAM crossbar array through a Wishbone slave interface.
//--------------------------------------------------------------------------------------------------

`timescale 1ns / 1ps

module tb_ReRAM_Wishbone_Interface;

  //------------------------------------------------------------------------------------------
  // DUT Interface Signals (Wishbone Bus + Memory Data)
  //------------------------------------------------------------------------------------------
  reg         wb_clk_i;
  reg         wb_rst_i;
  reg         wbs_stb_i;
  reg         wbs_cyc_i;
  reg         wbs_we_i;
  reg  [3:0]  wbs_sel_i;
  reg  [31:0] wbs_dat_i;
  reg  [31:0] wbs_adr_i;
  wire        wbs_ack_o;
  wire [31:0] wbs_dat_o;

  // Test variables for generating random access patterns
  reg [4:0] row_addr;
  reg [4:0] col_addr;
  reg [7:0] rand_data;


  //------------------------------------------------------------------------------------------
  // DUT Instantiation
  //------------------------------------------------------------------------------------------
  ReRAM_Wishbone_Interface dut (
    .wb_clk_i   (wb_clk_i),
    .wb_rst_i   (wb_rst_i),
    .wbs_stb_i  (wbs_stb_i),
    .wbs_cyc_i  (wbs_cyc_i),
    .wbs_we_i   (wbs_we_i),
    .wbs_sel_i  (wbs_sel_i),
    .wbs_dat_i  (wbs_dat_i),
    .wbs_adr_i  (wbs_adr_i),
    .wbs_ack_o  (wbs_ack_o),
    .wbs_dat_o  (wbs_dat_o)
  );

  //------------------------------------------------------------------------------------------
  // Clock Generation (100 MHz → 10 ns period)
  //------------------------------------------------------------------------------------------
  initial wb_clk_i = 0;
  always #5 wb_clk_i = ~wb_clk_i;

  //------------------------------------------------------------------------------------------
  // Task: Perform multiple Wishbone writes with randomized address and data
  //------------------------------------------------------------------------------------------
  task wishbone_write_mul;
    input integer count;
    integer k;
    begin
      @(posedge wb_clk_i);
      for (k = 0; k < count; k = k + 1) begin
        row_addr  = $random;
        col_addr  = $random;
        rand_data = $random;

        wbs_stb_i = 1;
        wbs_cyc_i = 1;
        wbs_we_i  = 0;                        // Write mode
        wbs_adr_i = 32'h3000_000c;            // Fixed address
        wbs_sel_i = 4'b0010;

        wbs_dat_i = {2'b00, row_addr, col_addr, 4'b0000, 8'h00, rand_data}; 

        $display($realtime, " [WRITE] row=%0d col=%0d data=0x%0h", row_addr, col_addr, rand_data);

        @(posedge wb_clk_i);
        wait (wbs_ack_o == 1'b1);
      end

      // Deassert control signals
      wbs_stb_i <= 0;
      wbs_cyc_i <= 0;
    end
  endtask

  //------------------------------------------------------------------------------------------
  // Task: Perform multiple sequential read transactions
  //------------------------------------------------------------------------------------------
  task wishbone_read_mul;
    input integer count;
    integer ack_count;
    begin
      ack_count = 0;
      @(posedge wb_clk_i);

      wbs_stb_i <= 1;
      wbs_cyc_i <= 1;
      wbs_we_i  <= 1;                         // Read mode
      wbs_adr_i <= 32'h3000_000c;
      wbs_sel_i <= 4'b0010;

      while (ack_count < count) begin
        @(posedge wb_clk_i);
        if (wbs_ack_o == 1'b1) begin
          $display("[READ] dat_o = %h @ time %0t", wbs_dat_o, $time);
          ack_count = ack_count + 1;
        end
      end

      wbs_stb_i <= 0;
      wbs_cyc_i <= 0;
    end
  endtask

  //------------------------------------------------------------------------------------------
  // Main Test Sequence
  //------------------------------------------------------------------------------------------
  initial begin
    // Initialize all inputs
    wb_rst_i    = 0;
    wbs_stb_i   = 0;
    wbs_cyc_i   = 0;
    wbs_we_i    = 0;
    wbs_sel_i   = 4'b0000;
    wbs_adr_i   = 32'd0;
    wbs_dat_i   = 32'd0;

    // Apply reset
    #20 wb_rst_i = 1;

    // Scenario 1: Write 32 entries, Read 20
    @(posedge wb_clk_i);
    wishbone_write_mul(32);
    #3300;
    wishbone_read_mul(20);
    #100;

    // Scenario 2: Write 10 more, Read 20
    @(posedge wb_clk_i);
    wishbone_write_mul(10);
    #1100;
    wishbone_read_mul(20);
    #100;

    // Scenario 3: Write 30 entries, Read 32
    @(posedge wb_clk_i);
    wishbone_write_mul(30);
    #2550;
    wishbone_read_mul(32);
    #100;

    // Scenario 4: Reset mid-operation
    wb_rst_i = 0;
    #20 wb_rst_i = 1;

    // Scenario 5: Write 10 entries, Read 7
    @(posedge wb_clk_i);
    wishbone_write_mul(10);
    #900;
    wishbone_read_mul(7);
    #3000;

    $finish;
  end

endmodule
