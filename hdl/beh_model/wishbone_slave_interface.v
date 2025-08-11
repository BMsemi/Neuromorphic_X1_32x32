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
// FILE NAME     : wishbone_slave_interface.v
//--------------------------------------------------------------------------------------------------
// Description:
//   Top-level wrapper that integrates the Wishbone protocol handler (slave interface)
//   with the ReRAM functional block. Analog pins are connected; scan/test pins removed.
//--------------------------------------------------------------------------------------------------

`timescale 1ns / 1ps

module wishbone_slave_interface (
  // Wishbone bus inputs
  input         wb_clk_i,      // Wishbone clock
  input         wb_rst_i,      // Wishbone reset (active low)
  input         wbs_stb_i,     // Wishbone strobe signal
  input         wbs_cyc_i,     // Wishbone cycle valid
  input         wbs_we_i,      // Wishbone write enable (0 = write, 1 = read)
  input  [31:0] wbs_adr_i,     // Wishbone address
  input  [31:0] wbs_dat_i,     // Wishbone write data
  input  [3:0]  wbs_sel_i,     // Wishbone byte select

  // Wishbone bus outputs
  output [31:0] wbs_dat_o,     // Wishbone read data
  output        wbs_ack_o,     // Wishbone acknowledge

  // Outputs to functional ReRAM core
  output        R_WB,          // Read/Write control signal to ReRAM core (1 = read, 0 = write)
  output        EN,            // Enable signal to trigger core operation
  output        CLKin,         // Clock to core
  output        RSTin,         // Reset to core
  output [31:0] DI,            // Data input to core
  output [3:0]  SEL,           // Byte select to core
  output [31:0] AD,            // Address to core

  // Inputs from functional ReRAM core
  input  [31:0] DO,            // Data output from core
  input         func_ack       // Acknowledge signal from core
);

  //------------------------------------------------------------------------------------------------
  // Parameter: Target address to decode Wishbone access. Transaction is only accepted for this addr.
  //------------------------------------------------------------------------------------------------
  parameter [31:0] ADDR_MATCH = 32'h3000_000c;

  //------------------------------------------------------------------------------------------------
  // Generate Enable signal when a valid Wishbone transaction matches the specified address
  //------------------------------------------------------------------------------------------------
  assign EN       = (wbs_stb_i && wbs_cyc_i && (wbs_adr_i == ADDR_MATCH) && (wbs_sel_i == 4'b0010));

  //------------------------------------------------------------------------------------------------
  // Pass decoded Wishbone inputs to functional block (ReRAM core)
  //------------------------------------------------------------------------------------------------
  assign R_WB     = wbs_we_i;
  assign CLKin    = wb_clk_i;
  assign RSTin    = wb_rst_i;
  assign DI       = wbs_dat_i;
  assign SEL      = wbs_sel_i;
  assign AD       = wbs_adr_i;

  //------------------------------------------------------------------------------------------------
  // Connect read data and acknowledge signal from core to Wishbone outputs
  //------------------------------------------------------------------------------------------------
  assign wbs_dat_o = DO;
  assign wbs_ack_o = func_ack;

endmodule
