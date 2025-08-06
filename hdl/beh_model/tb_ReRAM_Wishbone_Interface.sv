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
  logic         wb_clk_i;       // Wishbone clock
  logic         wb_rst_i;       // Wishbone reset (active low)
  logic         wbs_stb_i;      // Strobe signal to indicate valid bus cycle
  logic         wbs_cyc_i;      // Cycle valid signal
  logic         wbs_we_i;       // Write enable (0 = Write, 1 = Read)
  logic  [3:0]  wbs_sel_i;      // Byte enable signals
  logic  [31:0] wbs_dat_i;      // Data to be written
  logic  [31:0] wbs_adr_i;      // Address
  logic         wbs_ack_o;      // Acknowledge from slave
  logic  [31:0] wbs_dat_o;      // Data read from slave

  // Test variables for generating random access patterns
  logic [4:0] row_addr;
  logic [4:0] col_addr;
  logic [7:0] rand_data;

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
  task wishbone_write_mul(int count);
    begin
      @(posedge wb_clk_i);
      for (int i = 0; i < count; i++) begin
        row_addr  = $random;
        col_addr  = $random;
        rand_data = $random;

        wbs_stb_i = 1;
        wbs_cyc_i = 1;
        wbs_we_i  = 0;                        // Write mode
        wbs_adr_i = 32'h3000_000c;            // Fixed memory-mapped address
        wbs_sel_i = 4'b0010;

        // Format: 2b pad + 5b row + 5b col + 4b reserved + 8b dummy + 8b data
        wbs_dat_i = {2'b00, row_addr, col_addr, 4'b0000, 8'h00, rand_data}; 

        $display($realtime, " [WRITE] row=%0d col=%0d data=0x%0h", row_addr, col_addr, rand_data);

        @(posedge wb_clk_i);
        wait (wbs_ack_o);                     // Wait for acknowledge
      end

      // Deassert control signals
      wbs_stb_i <= 0;
      wbs_cyc_i <= 0;
    end
  endtask

  //------------------------------------------------------------------------------------------
  // Task: Perform multiple sequential read transactions from the fixed memory address
  //------------------------------------------------------------------------------------------
  task wishbone_read_mul(int count);
    automatic int ack_count = 0;
    //automatic int cycle_count = 0;
    begin
      @(posedge wb_clk_i);
      wbs_stb_i <= 1;
      wbs_cyc_i <= 1;
      wbs_we_i  <= 1;                         // Read mode
      wbs_adr_i <= 32'h3000_000c;
      wbs_sel_i <= 4'b0010;

      while (ack_count < count) begin
      // while ((ack_count < count) && (cycle_count < 50)) begin
        @(posedge wb_clk_i);
        // cycle_count++;

        if (wbs_ack_o) begin
          $display("[READ] dat_o = %h @ time %0t", wbs_dat_o, $time);
          ack_count++;
        end
      end

      // End the transaction
      wbs_stb_i <= 0;
      wbs_cyc_i <= 0;
    end
  endtask

  //------------------------------------------------------------------------------------------
  // Main Test Sequence
  // Includes various scenarios: full buffer, partial writes/reads, reset during ops
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

    // NOTE: Each write takes ~100ns after 'EN' deasserts. So delay = #entries * 100 + buffer

    // Scenario 1: Write 32 entries, Read 20
    @(posedge wb_clk_i);
    wishbone_write_mul(32);
    #3300;
    wishbone_read_mul(20);
    #100;

    // Scenario 2: Write 10 more, Read 22 (12 from previous + 10 new)
    @(posedge wb_clk_i);
    wishbone_write_mul(10);
    #1100;
    wishbone_read_mul(22);
    #100;

    // Scenario 3: Write 25 entries, Read 15
    @(posedge wb_clk_i);
    wishbone_write_mul(25);
    #2550;
    wishbone_read_mul(15);
    #100;

    // Scenario 4: Apply reset mid-operation
    wb_rst_i = 0;
    #20 wb_rst_i = 1;

    // Scenario 5: Write 7 entries, Read 7
    @(posedge wb_clk_i);
    wishbone_write_mul(7);
    #900;
    wishbone_read_mul(7);
    #3000;

    // End simulation
    $finish;
  end

endmodule
