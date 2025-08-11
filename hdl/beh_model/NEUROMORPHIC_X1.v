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

`timescale 1 ns / 1 ps

module NEUROMORPHIC_X1 (
    input         CLKin,        // Clock input
    input         RSTin,        // Asynchronous active-low reset
    input         EN,           // Enable from Wishbone interface
    input         R_WB,         // 1 = Read, 0 = Write
    input  [31:0] DI,           // Wishbone write data
    input  [31:0] AD,           // Wishbone address
    input  [3:0]  SEL,          // Byte select from Wishbone
    output [31:0] DO,           // Output read data
    output        func_ack,     // Acknowledge signal to Wishbone slave

    // Test and scan inputs (unused here)
    input         TM,
    input         SM,
    input         ScanInCC,
    input         ScanInDL,
    input         ScanInDR,
    output        ScanOutCC,

    // Analog / Power Pins
    input         VDDC,
    input         VDDA,
    input         VSS,
    input         Iref,
    input         Vbias,
    input         Vcomp,
    input         Bias_comp1,
    input         Bias_comp2,
    input         Ramp,
    input         Vcc_L,
    input         Vcc_Body,
    input         VCC_reset,
    input         VCC_set,
    input         VCC_wl_reset,
    input         VCC_wl_set,
    input         VCC_wl_read,
    input         VCC_read
);

    NEUROMORPHIC_X1_macro NEUROMORPHIC_X1_inst (
        .CLKin(CLKin),
        .RSTin(RSTin),
        .EN(EN),
        .R_WB(R_WB),
        .DI(DI),
        .AD(AD),
        .SEL(SEL),
        .DO(DO),
        .func_ack(func_ack),

        .TM(TM),
        .SM(SM),
        .ScanInCC(ScanInCC),
        .ScanInDL(ScanInDL),
        .ScanInDR(ScanInDR),
        .ScanOutCC(ScanOutCC),

        .VDDC(VDDC),
        .VDDA(VDDA),
        .VSS(VSS),
        .Iref(Iref),
        .Vbias(Vbias),
        .Vcomp(Vcomp),
        .Bias_comp1(Bias_comp1),
        .Bias_comp2(Bias_comp2),
        .Ramp(Ramp),
        .Vcc_L(Vcc_L),
        .Vcc_Body(Vcc_Body),
        .VCC_reset(VCC_reset),
        .VCC_set(VCC_set),
        .VCC_wl_reset(VCC_wl_reset),
        .VCC_wl_set(VCC_wl_set),
        .VCC_wl_read(VCC_wl_read),
        .VCC_read(VCC_read)
    );

endmodule
