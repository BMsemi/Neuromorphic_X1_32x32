//--------------------------------------------------------------------------------------------------
//  _  __  _       ___    _  __    ___  __   __  ___   _____   ___   __  __   ___
// | |/ / | |     / _ \  | |/ /   / __| \ \ / / / __| |_   _| | __| |  \/  | / __|
// | ' <  | |__  | (_) | | ' <    \__ \  \ V /  \__ \   | |   | _|  | |\/| | \__ \
// |_|\_\ |____|  \___/  |_|\_\   |___/   |_|   |___/   |_|   |___| |_|  |_| |___/
//
// This program is Confidential and Proprietary product of Klok Systems. Any unauthorized use,
// reproduction or transfer of this program is strictly prohibited unless written authorization
// from Klok Systems. (c) 2019 Klok Systems India Private Limited - All Rights Reserved
//--------------------------------------------------------------------------------------------------
// FILE NAME     : NEUROMORPHIC_X1_macro.v
// AUTHOR        :
//--------------------------------------------------------------------------------------------------
// Description:
//   Behavioral-only simulation model of a 32x32 ReRAM memory array using queues.
//   Not synthesizable. Supports programmable delays for read/write operations.
//--------------------------------------------------------------------------------------------------

`timescale 1ns / 1ps

module NEUROMORPHIC_X1_macro (
  input  wire        CLKin,        // Clock input
  input  wire        RSTin,        // Asynchronous active-low reset
  input  wire        EN,           // Enable from Wishbone interface
  input  wire        R_WB,         // 1 = Read, 0 = Write
  input  wire [31:0] DI,           // Wishbone write data
  input  wire [31:0] AD,           // Wishbone address
  input  wire [3:0]  SEL,          // Byte select from Wishbone
  output reg  [31:0] DO,           // Output read data
  output reg         func_ack,     // Acknowledge signal to Wishbone slave

  // Test and scan inputs (unused here)
  input  wire        TM,
  input  wire        SM,
  input  wire        ScanInCC,
  input  wire        ScanInDL,
  input  wire        ScanInDR,
  output wire        ScanOutCC,
	
	// Analog Pins
	input  VDDC,
	input  VDDA,
	input  VSS,
	input  Iref,
	input  Vbias,
	input  Vcomp,
	input  Bias_comp1,
	input  Bias_comp2,
	input  Ramp,
	input  Vcc_L,
	input  Vcc_Body,
	input  VCC_reset,
	input  VCC_set,
	input  VCC_wl_reset,
	input  VCC_wl_set,
	input  VCC_wl_read,
	input  VCC_read
);

  //------------------------------------------------------------------------------------------------
  // Parameters: Configurable simulation delays
  //------------------------------------------------------------------------------------------------
  parameter RD_Dly       = 0;  // Clock cycles delay before read data becomes valid
  parameter WR_Dly       = 0;  // Write delay (simulate ~44K cycles for real chip)
  parameter RD_Data_hold = 1;   // Hold read data for this many cycles

  //------------------------------------------------------------------------------------------------
  // Internal memory and arrays
  //------------------------------------------------------------------------------------------------
  reg [7:0]  array_mem [0:31][0:31];          // 32x32 memory array (2D)
  reg [31:0] ip_queue_data [0:31];             // Write queue (fixed size array)
  reg [31:0] array_mem_queue [0:31];          // Stores address/data for read (fixed size array)
  reg [31:0] ip_reg, op_reg;        // Temp registers

  // Queue management pointers
  reg [5:0] ip_queue_head, ip_queue_tail;     // Write queue pointers
  reg [5:0] array_queue_head, array_queue_tail; // Read queue pointers
  reg [5:0] ip_queue_size, array_queue_size;  // Queue sizes

  integer count;     // Total transactions count (pending reads/writes)
  integer wr_count;  // Pending write transaction count (for simulating delay)
  integer i, j, k;      // Loop counters

  // Queue management functions implemented as tasks
  task push_ip_queue;
    input [31:0] data;
    begin
      if (ip_queue_size < 32) begin
        ip_queue_data[ip_queue_head] = data;
        ip_queue_head = (ip_queue_head + 1) % 32;
        ip_queue_size = ip_queue_size + 1;
      end
    end
  endtask

  task pop_ip_queue;
    output [31:0] data;
    begin
      if (ip_queue_size > 0) begin
        data = ip_queue_data[ip_queue_tail];
        ip_queue_tail = (ip_queue_tail + 1) % 32;
        ip_queue_size = ip_queue_size - 1;
      end
    end
  endtask

  task push_array_queue;
    input [31:0] data;
    begin
      if (array_queue_size < 32) begin
        array_mem_queue[array_queue_head] = data;
        array_queue_head = (array_queue_head + 1) % 32;
        array_queue_size = array_queue_size + 1;
      end
    end
  endtask

  task pop_array_queue;
    output [31:0] data;
    begin
      if (array_queue_size > 0) begin
        data = array_mem_queue[array_queue_tail];
        array_queue_tail = (array_queue_tail + 1) % 32;
        array_queue_size = array_queue_size - 1;
      end
    end
  endtask

  //------------------------------------------------------------------------------------------------
  // Main FSM: Reset, Write, Read
  //------------------------------------------------------------------------------------------------
  always @(posedge CLKin or posedge RSTin) begin
    if (RSTin) begin
      // Asynchronous reset
      func_ack <= 1'b0;
      DO       <= 32'd0;
      
      // Reset queue pointers and sizes
      ip_queue_head <= 6'd0;
      ip_queue_tail <= 6'd0;
      ip_queue_size <= 6'd0;
      array_queue_head <= 6'd0;
      array_queue_tail <= 6'd0;
      array_queue_size <= 6'd0;
      
      count    <= 0;
      wr_count <= 0;

    end else begin
      func_ack <= 1'b0;

      //--------------------------------------------------------------------------------------------
      // WRITE OPERATION: Valid EN + Write mode
      //--------------------------------------------------------------------------------------------
      if (EN && R_WB && count < 32) begin
        push_ip_queue(DI);                    // Add data to write queue
        count = count + 1;
        wr_count = wr_count + 1;
        func_ack <= 1'b1;

        if (ip_queue_size > 0) begin
          pop_ip_queue(ip_reg);                                    // Get oldest data
          push_array_queue(ip_reg);                                // Track for read
          array_mem[ip_reg[29:25]][ip_reg[24:20]] = ip_reg[7:0];   // Store 8-bit data in 2D array
        end

        $display("[WRITE] @%0t: Pushed %h | Count = %0d", $realtime, DI, count);

        if (count == 32)
          $display("[INFO] FIFO Full, Cannot Perform Write Operation");

      //--------------------------------------------------------------------------------------------
      // READ OPERATION: Valid EN + Read mode + data available
      //--------------------------------------------------------------------------------------------
      end else if (EN && !R_WB && array_queue_size > 0) begin
        // Simulate programmable delay before data available
        for (i = 0; i < RD_Dly; i = i + 1) begin
          @(posedge CLKin);
          if (!EN) begin
            $display("[READ] Aborted early @%0t", $realtime);
            i = RD_Dly; // Break out of loop
          end
        end

        if (EN) begin // Check if still enabled after delay
          // Pop oldest address, perform 8-bit read and zero-pad
          pop_array_queue(op_reg);
          DO = {24'd0, array_mem[op_reg[29:25]][op_reg[24:20]]};  // Read from 2D array
          func_ack <= 1'b1;
          count = count - 1;

          $display("[READ] @%0t: Popped %h | Count = %0d", $realtime, DO, count);

          // Hold read data for RD_Data_hold cycles
          for (j = 0; j < RD_Data_hold; j = j + 1) begin
            @(posedge CLKin);
          end
          func_ack <= 1'b0;

          if (count == 0) begin
            $display("[INFO] FIFO Empty, Cannot Perform Read Operation");
          end
        end

      //--------------------------------------------------------------------------------------------
      // IDLE Delay: Simulate post-write delay even when no EN
      //--------------------------------------------------------------------------------------------
      end else if (!EN && wr_count > 0) begin
        for (k = wr_count; k > 0; k = k - 1) begin
          repeat (WR_Dly) @(posedge CLKin);
        end
        wr_count = 0;
      end
    end
  end

  // Assign unused scan output
  assign ScanOutCC = 1'b0;

endmodule
