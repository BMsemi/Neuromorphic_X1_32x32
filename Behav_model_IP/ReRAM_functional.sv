//--------------------------------------------------------------------------------------------------
//  _  __  _       ___    _  __    ___  __   __  ___   _____   ___   __  __   ___
// | |/ / | |     / _ \  | |/ /   / __| \ \ / / / __| |_   _| | __| |  \/  | / __|
// | ' <  | |__  | (_) | | ' <    \__ \  \ V /  \__ \   | |   | _|  | |\/| | \__ \
// |_|\_\ |____|  \___/  |_|\_\   |___/   |_|   |___/   |_|   |___| |_|  |_| |___/
//
// This program is Confidential and Proprietary product of Klok Systems. Any unauthorized use,
// reproduction or transfer of this program is strictly prohibited unless written authorization
// from Klok Systems. (c) 2019 Klok Systems India Private Limited - All Rights Reserved
//-------------------------------------------------------------------------------------------------
// FILE NAME     : ReRAM_functional
// AUTHOR        :
//-------------------------------------------------------------------------------------------------
// Description:
// This module emulates the core functional behavior of a ReRAM-based memory with a Wishbone
// interface. It handles 8-bit wide storage in a 32x32 array with delay-simulated read/write.
// All operations are simulation-only using SystemVerilog queues (not synthesizable).
//-------------------------------------------------------------------------------------------------

`timescale 1ns / 1ps

module ReRAM_functional (
  input  logic        wb_clk_i,     // System clock input
  input  logic        wb_rst_i,     // Asynchronous active-low reset
  input  logic        EN,           // Enable signal indicating valid Wishbone transaction
  input  logic        R_WB,         // 1 = Read, 0 = Write (decoded from Wishbone WE)
  input  logic [31:0] wbs_dat_i,    // Wishbone write data
  output logic [31:0] read_data,    // Output read data (valid for read operations)
  output logic        func_ack      // Acknowledge signal to Wishbone slave
);

  //------------------------------------------------------------------------------------------------
  // Parameters for read/write timing simulation
  //------------------------------------------------------------------------------------------------
  parameter RD_Dly       = 44;  // Number of clock cycles to delay read
  parameter WR_Dly       = 10;   // Actual Value is 44_000 (But for Siumulation Purpose we take as 10)
  parameter RD_Data_hold = 1;   // Number of cycles to hold read data

  //------------------------------------------------------------------------------------------------
  // Internal queues and memory
  //------------------------------------------------------------------------------------------------
  logic [31:0] ip_queue_data [$];      // Input write queue
  logic [31:0] array_mem_queue [$];    // Queue to store addresses for readback
  logic [31:0] ip_reg, op_reg, op_reg_1;

  logic [7:0] array_mem [0:31][0:31];  // 32x32 array of 8-bit memory cells
  int count = 0;                       // Tracks total queued transactions
  int wr_count = 0;                       // Tracks total queued transactions

  //------------------------------------------------------------------------------------------------
  // Main sequential logic for reset, write, and read handling
  //------------------------------------------------------------------------------------------------
  always @(posedge wb_clk_i or negedge wb_rst_i) begin
    if (!wb_rst_i) begin
      // Reset behavior
      func_ack <= 0;
      read_data <= 32'd0;
      ip_queue_data.delete();
      array_mem_queue.delete();
      count <= 0;
    end else begin
      func_ack <= 0;

      //--------------------------------------------------------------------------------------------
      // WRITE Operation: EN is high, R_WB = 0, queue not full
      //--------------------------------------------------------------------------------------------
      if (EN && !R_WB && count < 32) begin
        ip_queue_data.push_front(wbs_dat_i);  // Add new data to front of write queue
        count++;
				wr_count++;
        func_ack <= 1;                        // Acknowledge write

        if (ip_queue_data.size() > 0) begin
          ip_reg = ip_queue_data.pop_back(); // Pop oldest value from back
          array_mem_queue.push_front(ip_reg); // Track the address for future read
          array_mem[ip_reg[29:25]][ip_reg[24:20]] = ip_reg[7:0]; // Write only lower 8 bits
        end

        $display("[WRITE] @%0t: Pushed %h | Count = %0d", $realtime, wbs_dat_i, count);
				
				if(count == 'd32) $display("[INFO] FIFO Full, Cannot Perform Write Operation");

      //--------------------------------------------------------------------------------------------
      // READ Operation: EN is high, R_WB = 1, and something to read
      //--------------------------------------------------------------------------------------------
      end else if (EN && R_WB && array_mem_queue.size() > 0) begin
        read_sequence: begin
          // Simulate programmable read delay
          for (int i = 0; i < RD_Dly; i++) begin
            if (!EN) begin
              $display("[READ] Aborted early @%0t", $realtime);
              disable read_sequence;
            end
            @(posedge wb_clk_i);
          end

          // Perform read from array memory using stored address
          op_reg   = array_mem_queue.pop_back();
          op_reg_1 = {24'd0, array_mem[op_reg[29:25]][op_reg[24:20]]}; // Pad 8-bit data to 32 bits
          read_data <= op_reg_1;
          func_ack  <= 1;
          count--;

          $display("[READ] @%0t: Popped %h | Count = %0d", $realtime, op_reg_1, count);

          // Hold read data for RD_Data_hold cycles
          for (int j = 0; j < RD_Data_hold; j++) @(posedge wb_clk_i);
          func_ack <= 0;
					
					if(count == 0) begin
					  $display("[INFO] FIFO Empty, Cannot Perform Read Operation");
						disable read_sequence;
					end
				end
				
      end else if(!EN && wr_count>0) begin
		    for(int i = wr_count; i>0  ; i--) begin
		      repeat(WR_Dly) @(posedge wb_clk_i);
			  end
			  wr_count = 0;
		  end
    end
  end

endmodule
