// SPDX-FileCopyrightText: 2024 BM Labs and its Licensors, All Rights Reserved
// ========================================================================================
//
//  This software is protected by copyright and other intellectual property
//  rights. Therefore, reproduction, modification, translation, compilation, or
//  representation of this software in any manner other than expressly permitted
//  is strictly prohibited.
//
//  You may access and use this software, solely as provided, solely for the purpose of
//  integrating into semiconductor chip designs that you create as a part of the
//  BM Labs production programs (and solely for use and fabrication as a part of
//  BM Labs production purposes and for no other purpose.  You may not modify or
//  convey the software for any other purpose.
//
//  Disclaimer: BM LABS AND ITS LICENSORS MAKE NO WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, WITH REGARD TO THIS MATERIAL, AND EXPRESSLY DISCLAIM
//  ANY AND ALL WARRANTIES OF ANY KIND INCLUDING, BUT NOT LIMITED TO, THE
//  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
//  PURPOSE. BM Labs reserves the right to make changes without further
//  notice to the materials described herein. Neither BM Labs nor any of its licensors
//  assume any liability arising out of the application or use of any product or
//  circuit described herein. BM Labs products described herein are
//  not authorized for use as components in life-support devices.
//
//  If you have a separate agreement with BM Labs pertaining to the use of this software
//  then that agreement shall control.

`timescale 1ns / 1ps

module NEUROMORPHIC_X1_macro (
  user_clk, user_rst, wb_clk_i, wb_rst_i, wb_adr_i, wb_dat_i, wb_cyc_i, wb_stb_i, wb_we_i, wb_sel_i, 
  ScanInCC, ScanInDL, ScanInDR, ScanOutCC,
  TM, wbs_dat_o, wbs_ack_o, 
  VDDC, VSS, Iref, Vbias, Vcomp, Bias_comp1, Bias_comp2, Ramp, 
  Vcc_L, Vcc_Body, VCC_reset, VCC_set, VCC_wl_reset, VCC_wl_set, VCC_wl_read, VCC_read, VDDA
);

  //--------------------------------------
  // Inputs
  //--------------------------------------
  input         user_clk;       // Clock input
  input         user_rst;       // Reset input
  input         wb_clk_i;       // Wishbone clock input
  input         wb_rst_i;       // Wishbone reset input
  input  [31:0] wb_adr_i;       // Wishbone address input
  input  [31:0] wb_dat_i;       // Wishbone data input
  input         wb_cyc_i;       // Wishbone cycle input
  input         wb_stb_i;       // Wishbone strobe input
  input         wb_we_i;        // Wishbone write enable input
  input  [3:0]  wb_sel_i;       // Wishbone select input

  input         ScanInCC;       // Scan chain input for clock control
  input         ScanInDL;       // Scan chain input for delay line
  input         ScanInDR;       // Scan chain input for data register

  input         TM;             // Test mode input
  
  // Analog power and control inputs
  input         VDDC;           // Digital power supply
  input         VSS;            // Ground
  input         Iref;           // Reference current
  input         Vbias;          // Bias voltage
  input         Vcomp;          // Compensation voltage
  input         Bias_comp1;     // Bias comparator 1
  input         Bias_comp2;     // Bias comparator 2
  input         Ramp;           // Ramp signal
  input         Vcc_L;          // Low voltage supply
  input         Vcc_Body;       // Body voltage supply
  input         VCC_reset;      // Power supply reset
  input         VCC_set;        // Power supply set
  input         VCC_wl_reset;   // Word line reset
  input         VCC_wl_set;     // Word line set
  input         VCC_wl_read;    // Word line read
  input         VCC_read;       // Read voltage supply
  input         VDDA;           // Analog power supply

  //--------------------------------------
  // Outputs
  //--------------------------------------
  output [31:0] wbs_dat_o;      // Wishbone data output
  output        wbs_ack_o;      // Wishbone acknowledge output
  output        ScanOutCC;      // Scan chain output for clock control

endmodule
