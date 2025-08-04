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
// FILE NAME     : ReRAM_Wishbone_Interface
// AUTHOR        :
//-------------------------------------------------------------------------------------------------
// Description:
// Top-level wrapper that integrates the Wishbone protocol handler (slave interface)
// with the ReRAM functional block. This design splits control logic and memory logic
// for modularity and ease of simulation and testability.
//-------------------------------------------------------------------------------------------------

`timescale 1ns / 1ps

module ReRAM_Wishbone_Interface (
  input  logic        wb_clk_i,     // Wishbone clock
  input  logic        wb_rst_i,     // Wishbone reset (active high)
  input  logic        wbs_stb_i,    // Wishbone strobe
  input  logic        wbs_cyc_i,    // Wishbone cycle indicator
  input  logic        wbs_we_i,     // Wishbone write enable: 0=write, 1=read
  input  logic [3:0]  wbs_sel_i,    // Wishbone byte select
  input  logic [31:0] wbs_dat_i,    // Wishbone write data
  input  logic [31:0] wbs_adr_i,    // Wishbone address
  output logic        wbs_ack_o,    // Wishbone acknowledge output
  output logic [31:0] wbs_dat_o     // Wishbone read data output
);

  // Internal signals to connect protocol and functional blocks
  logic EN;               // Enable signal from Wishbone interface to functional block
  logic R_WB;             // Read/Write control: 1 = read, 0 = write
  logic func_ack;         // Acknowledge signal from functional block
  logic [31:0] read_data; // Data from functional block to be passed to Wishbone

  //----------------------------------------------------------------------------------------------
  // Instantiate Wishbone slave interface
  // This handles protocol decoding, generates EN and R_WB signals, and routes ack/data signals
  //----------------------------------------------------------------------------------------------
  wishbone_slave_interface wishbone_if (
    .wb_clk_i    (wb_clk_i),
    .wb_rst_i    (wb_rst_i),
    .wbs_stb_i   (wbs_stb_i),
    .wbs_cyc_i   (wbs_cyc_i),
    .wbs_we_i    (wbs_we_i),
    .wbs_adr_i   (wbs_adr_i),
    .wbs_sel_i   (wbs_sel_i),
    .wbs_dat_i   (wbs_dat_i),
    .wbs_dat_o   (wbs_dat_o),    // Output read data passed from functional block
    .wbs_ack_o   (wbs_ack_o),    // Acknowledge driven by functional block
    .R_WB        (R_WB),         // Read/write flag
    .EN          (EN),           // Transaction enable
    .read_data   (read_data),    // Data from memory (functional block)
    .func_ack    (func_ack)      // Functional block ack
  );

  //----------------------------------------------------------------------------------------------
  // Instantiate ReRAM functional block
  // Handles memory logic including 32x32 array, queues, delays, and read/write state
  //----------------------------------------------------------------------------------------------
  ReRAM_functional functional (
    .wb_clk_i   (wb_clk_i),
    .wb_rst_i   (wb_rst_i),
    .EN         (EN),           // Trigger for memory transaction
    .R_WB       (R_WB),         // Read/Write control
    .wbs_dat_i  (wbs_dat_i),    // Input data for write
    .read_data  (read_data),    // Output data for read
    .func_ack   (func_ack)      // Acknowledge to interface
  );

endmodule
