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
    input  logic        CLKin,         // Clock input
    input  logic        RSTin,         // Reset
    input  logic        EN,            // Enable
    input  logic        R_WB,          // Read/Write select
    input  logic [31:0] DI,            // Write data
    input  logic [31:0] AD,            // Address
    input  logic [3:0]  SEL,           // Byte select
    output logic [31:0] DO,            // Read data
    output logic        func_ack,      // Acknowledge

    // Scan and test signals
    input  logic        TM,
    input  logic        SM,
    input  logic        ScanInCC,
    input  logic        ScanInDL,
    input  logic        ScanInDR,
    output logic        ScanOutCC,

    // Analog / Power signals
    input  logic        VDD,
    input  logic        VSS,
    input  logic        Iref,
    input  logic        Vbias,
    input  logic        Vcomp,
    input  logic        Bias_comp1,
    input  logic        Bias_comp2,
    input  logic        Ramp,
    input  logic        Vcc_L,
    input  logic        Vcc_Body,
    input  logic        VCC_reset,
    input  logic        VCC_set,
    input  logic        VCC_wl_reset,
    input  logic        VCC_wl_set,
    input  logic        VCC_wl_read,
    input  logic        VCC_read
);

endmodule
