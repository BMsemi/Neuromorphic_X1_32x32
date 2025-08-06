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
// FILE NAME     : NEUROMORPHIC_X1_macro.sv
// AUTHOR        :
//--------------------------------------------------------------------------------------------------
// Description:
//   Behavioral-only simulation model of a 32x32 ReRAM memory array using queues.
//   Not synthesizable. Supports programmable delays for read/write operations.
//--------------------------------------------------------------------------------------------------

`timescale 1ns / 1ps

module NEUROMORPHIC_X1_macro (
  input  logic        CLKin,        // Clock input
  input  logic        RSTin,        // Asynchronous active-low reset
  input  logic        EN,           // Enable from Wishbone interface
  input  logic        R_WB,         // 1 = Read, 0 = Write
  input  logic [31:0] DI,           // Wishbone write data
  input  logic [31:0] AD,           // Wishbone address
  input  logic [3:0]  SEL,          // Byte select from Wishbone
  output logic [31:0] DO,           // Output read data
  output logic        func_ack,     // Acknowledge signal to Wishbone slave

  // Test and scan inputs (unused here)
  input  logic        TM,
  input  logic        SM,
  input  logic        ScanInCC,
  input  logic        ScanInDL,
  input  logic        ScanInDR,
  output logic        ScanOutCC,
	
	// Ananlog Pins
	input  VDD,
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
  parameter RD_Dly       = 44;  // Clock cycles delay before read data becomes valid
  parameter WR_Dly       = 10;  // Write delay (simulate ~44K cycles for real chip)
  parameter RD_Data_hold = 1;   // Hold read data for this many cycles

  //------------------------------------------------------------------------------------------------
  // Internal memory and queues
  //------------------------------------------------------------------------------------------------
  logic [7:0]  array_mem [0:31][0:31];     // Actual 32x32 memory array
  logic [31:0] ip_queue_data [$];          // Write queue
  logic [31:0] array_mem_queue [$];        // Stores address/data for read
  logic [31:0] ip_reg, op_reg, op_reg_1;   // Temp registers

  int count    = 0;  // Total transactions count (pending reads/writes)
  int wr_count = 0;  // Pending write transaction count (for simulating delay)

  //------------------------------------------------------------------------------------------------
  // Main FSM: Reset, Write, Read
  //------------------------------------------------------------------------------------------------
  always @(posedge CLKin or negedge RSTin) begin
    if (!RSTin) begin
      // Asynchronous reset
      func_ack <= 0;
      DO       <= 32'd0;
      ip_queue_data.delete();
      array_mem_queue.delete();
      count    <= 0;
      wr_count <= 0;

    end else begin
      func_ack <= 0;

      //--------------------------------------------------------------------------------------------
      // WRITE OPERATION: Valid EN + Write mode
      //--------------------------------------------------------------------------------------------
      if (EN && !R_WB && count < 32) begin
        ip_queue_data.push_front(DI);       // Add data to write queue
        count++;
        wr_count++;
        func_ack <= 1;

        if (ip_queue_data.size() > 0) begin
          ip_reg = ip_queue_data.pop_back();              // Oldest data
          array_mem_queue.push_front(ip_reg);             // Track for read
          array_mem[ip_reg[29:25]][ip_reg[24:20]] = ip_reg[7:0]; // Store 8-bit data
        end

        $display("[WRITE] @%0t: Pushed %h | Count = %0d", $realtime, DI, count);

        if (count == 32)
          $display("[INFO] FIFO Full, Cannot Perform Write Operation");

      //--------------------------------------------------------------------------------------------
      // READ OPERATION: Valid EN + Read mode + data available
      //--------------------------------------------------------------------------------------------
      end else if (EN && R_WB && array_mem_queue.size() > 0) begin
        read_sequence: begin
          // Simulate programmable delay before data available
          for (int i = 0; i < RD_Dly; i++) begin
            if (!EN) begin
              $display("[READ] Aborted early @%0t", $realtime);
              disable read_sequence;
            end
            @(posedge CLKin);
          end

          // Pop oldest address, perform 8-bit read and zero-pad
          op_reg   = array_mem_queue.pop_back();
          op_reg_1 = {24'd0, array_mem[op_reg[29:25]][op_reg[24:20]]};
          DO       <= op_reg_1;
          func_ack <= 1;
          count--;

          $display("[READ] @%0t: Popped %h | Count = %0d", $realtime, op_reg_1, count);

          // Hold read data for RD_Data_hold cycles
          for (int j = 0; j < RD_Data_hold; j++) @(posedge CLKin);
          func_ack <= 0;

          if (count == 0) begin
            $display("[INFO] FIFO Empty, Cannot Perform Read Operation");
            disable read_sequence;
          end
        end

      //--------------------------------------------------------------------------------------------
      // IDLE Delay: Simulate post-write delay even when no EN
      //--------------------------------------------------------------------------------------------
      end else if (!EN && wr_count > 0) begin
        for (int i = wr_count; i > 0; i--) begin
          repeat (WR_Dly) @(posedge CLKin);
        end
        wr_count = 0;
      end
    end
  end

endmodule
