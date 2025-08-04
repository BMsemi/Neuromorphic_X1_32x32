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
// FILE NAME     : wishbone_slave_interface
// AUTHOR        :
//-------------------------------------------------------------------------------------------------
// Description:
// This module implements the Wishbone slave interface logic. It detects valid Wishbone
// transactions targeting a specific address and generates control signals for the
// functional block (ReRAM core). It also routes read data and acknowledge signals.
//-------------------------------------------------------------------------------------------------

`timescale 1ns / 1ps

module wishbone_slave_interface (
  input  logic        wb_clk_i,      // Wishbone clock
  input  logic        wb_rst_i,      // Wishbone reset (active low)
  input  logic        wbs_stb_i,     // Wishbone strobe signal
  input  logic        wbs_cyc_i,     // Wishbone cycle valid
  input  logic        wbs_we_i,      // Wishbone write enable (0 = write, 1 = read)
  input  logic [31:0] wbs_adr_i,     // Wishbone address
  input  logic [31:0] wbs_dat_i,     // Wishbone write data
  input  logic [3:0]  wbs_sel_i,     // Wishbone byte select

  output logic [31:0] wbs_dat_o,     // Wishbone read data
  output logic        wbs_ack_o,     // Wishbone acknowledge

  // Connections to functional block (ReRAM core)
  output logic        R_WB,          // Read/Write control signal to ReRAM core (1 = read, 0 = write)
  output logic        EN,            // Enable signal to trigger transaction in core
  input  logic [31:0] read_data,     // Data read from ReRAM core
  input  logic        func_ack       // Acknowledge from ReRAM core
);

  //------------------------------------------------------------------------------------------------
  // Parameter: target address to decode valid Wishbone access
  //------------------------------------------------------------------------------------------------
  parameter ADDR_MATCH = 32'h3000_000c;

  //------------------------------------------------------------------------------------------------
  // EN is asserted when a valid Wishbone transaction to ADDR_MATCH is seen
  //------------------------------------------------------------------------------------------------
  assign EN = (wbs_stb_i && wbs_cyc_i && (wbs_adr_i == ADDR_MATCH) && (wbs_sel_i == 4'b0010));

  //------------------------------------------------------------------------------------------------
  // R_WB is simply the write enable signal; passed to core to indicate read or write
  //------------------------------------------------------------------------------------------------
  assign R_WB = wbs_we_i;

  //------------------------------------------------------------------------------------------------
  // Connect read data and ack from core to Wishbone output signals
  //------------------------------------------------------------------------------------------------
  assign wbs_dat_o = read_data;
  assign wbs_ack_o = func_ack;

endmodule
