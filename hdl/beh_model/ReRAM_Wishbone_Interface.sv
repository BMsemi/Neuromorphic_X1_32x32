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
// FILE NAME     : ReRAM_Wishbone_Interface.sv
//--------------------------------------------------------------------------------------------------
// Description:
//   Top-level wrapper that integrates the Wishbone protocol handler (slave interface)
//   with the ReRAM functional block. Analog pins are connected; scan/test pins removed.
//--------------------------------------------------------------------------------------------------

`timescale 1ns / 1ps

module ReRAM_Wishbone_Interface (
  input  logic        wb_clk_i,     // Wishbone clock
  input  logic        wb_rst_i,     // Wishbone reset (active low)
  input  logic        wbs_stb_i,    // Wishbone strobe
  input  logic        wbs_cyc_i,    // Wishbone cycle indicator
  input  logic        wbs_we_i,     // Wishbone write enable: 0=write, 1=read
  input  logic [3:0]  wbs_sel_i,    // Wishbone byte select
  input  logic [31:0] wbs_dat_i,    // Wishbone write data
  input  logic [31:0] wbs_adr_i,    // Wishbone address
  output logic        wbs_ack_o,    // Wishbone acknowledge output
  output logic [31:0] wbs_dat_o,    // Wishbone read data output

  // Analog power/IO pins (to be driven in top-level SoC integration or testbench)
  input  logic VDD,
  input  logic VSS,
  input  logic Iref,
  input  logic Vbias,
  input  logic Vcomp,
  input  logic Bias_comp1,
  input  logic Bias_comp2,
  input  logic Ramp,
  input  logic Vcc_L,
  input  logic Vcc_Body,
  input  logic VCC_reset,
  input  logic VCC_set,
  input  logic VCC_wl_reset,
  input  logic VCC_wl_set,
  input  logic VCC_wl_read,
  input  logic VCC_read
);

  //------------------------------------------------------------------------------------------
  // Internal interconnect wires between Wishbone slave and functional block
  //------------------------------------------------------------------------------------------
  logic        EN;         // Enable signal for ReRAM operation
  logic        R_WB;       // Read/Write control: 1 = read, 0 = write
  logic        func_ack;   // Acknowledge from ReRAM block
  logic [31:0] DO;         // Data output from ReRAM block
  logic [3:0]  SEL;        // Byte select
  logic        CLKin;      // Clock routed to internal modules
  logic        RSTin;      // Reset routed to internal modules
  logic [31:0] DI;         // Data input to ReRAM functional block
  logic [31:0] AD;         // Address to ReRAM block

  //------------------------------------------------------------------------------------------
  // Wishbone Slave Interface Instantiation
  //------------------------------------------------------------------------------------------
  wishbone_slave_interface wishbone_if (
    .wb_clk_i    (wb_clk_i),
    .wb_rst_i    (wb_rst_i),
    .wbs_stb_i   (wbs_stb_i),
    .wbs_cyc_i   (wbs_cyc_i),
    .wbs_we_i    (wbs_we_i),
    .wbs_adr_i   (wbs_adr_i),
    .wbs_sel_i   (wbs_sel_i),
    .wbs_dat_i   (wbs_dat_i),
    .wbs_dat_o   (wbs_dat_o),
    .wbs_ack_o   (wbs_ack_o),
    .R_WB        (R_WB),
    .EN          (EN),
    .CLKin       (CLKin),
    .RSTin       (RSTin),
    .DI          (DI),
    .SEL         (SEL),
    .AD          (AD),
    .DO          (DO),
    .func_ack    (func_ack)
  );

  //------------------------------------------------------------------------------------------
  // ReRAM Functional Block Instantiation
  //------------------------------------------------------------------------------------------
  NEUROMORPHIC_X1 functional (
    .CLKin         (CLKin),
    .RSTin         (RSTin),
    .EN            (EN),
    .R_WB          (R_WB),
    .DI            (DI),
    .AD            (AD),
    .SEL           (SEL),
    .DO            (DO),
    .func_ack      (func_ack),

    // Analog signals
    .VDD           (VDD),
    .VSS           (VSS),
    .Iref          (Iref),
    .Vbias         (Vbias),
    .Vcomp         (Vcomp),
    .Bias_comp1    (Bias_comp1),
    .Bias_comp2    (Bias_comp2),
    .Ramp          (Ramp),
    .Vcc_L         (Vcc_L),
    .Vcc_Body      (Vcc_Body),
    .VCC_reset     (VCC_reset),
    .VCC_set       (VCC_set),
    .VCC_wl_reset  (VCC_wl_reset),
    .VCC_wl_set    (VCC_wl_set),
    .VCC_wl_read   (VCC_wl_read),
    .VCC_read      (VCC_read),

    // Scan/test pins
    .TM            (1'b0),
    .SM            (1'b0),
    .ScanInCC      (1'b0),
    .ScanInDL      (1'b0),
    .ScanInDR      (1'b0),
    .ScanOutCC     ()
  );

endmodule
