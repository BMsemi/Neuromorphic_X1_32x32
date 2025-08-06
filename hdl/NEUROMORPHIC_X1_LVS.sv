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
  DO, AD, DI, SEL, CLKin, RSTin, EN, R_WB, func_ack,
  TM, SM, ScanInCC, ScanInDL, ScanInDR, ScanOutCC,
  VDD, VSS, Iref, Vbias, Vcomp, Bias_comp1, Bias_comp2, Ramp,
  Vcc_L, Vcc_Body, VCC_reset, VCC_set, VCC_wl_reset, VCC_wl_set, VCC_wl_read, VCC_read
);

  output [31:0] DO;
  input  [31:0] DI;
  input  [31:0] AD;
  input  [3:0]  SEL;
  input         CLKin;
  input         RSTin;
  input         EN;
  input         R_WB;
  output        func_ack;

  input         TM;
  input         SM;
  input         ScanInCC;
  input         ScanInDL;
  input         ScanInDR;
  output        ScanOutCC;

  input         VDD;
  input         VSS;
  input         Iref;
  input         Vbias;
  input         Vcomp;
  input         Bias_comp1;
  input         Bias_comp2;
  input         Ramp;
  input         Vcc_L;
  input         Vcc_Body;
  input         VCC_reset;
  input         VCC_set;
  input         VCC_wl_reset;
  input         VCC_wl_set;
  input         VCC_wl_read;
  input         VCC_read;

  NEUROMORPHIC_X1_macro NEUROMORPHIC_X1_inst (
    .DO<31>(DO[31]), .DO<30>(DO[30]), .DO<29>(DO[29]), .DO<28>(DO[28]),
    .DO<27>(DO[27]), .DO<26>(DO[26]), .DO<25>(DO[25]), .DO<24>(DO[24]),
    .DO<23>(DO[23]), .DO<22>(DO[22]), .DO<21>(DO[21]), .DO<20>(DO[20]),
    .DO<19>(DO[19]), .DO<18>(DO[18]), .DO<17>(DO[17]), .DO<16>(DO[16]),
    .DO<15>(DO[15]), .DO<14>(DO[14]), .DO<13>(DO[13]), .DO<12>(DO[12]),
    .DO<11>(DO[11]), .DO<10>(DO[10]), .DO<9>(DO[9]),  .DO<8>(DO[8]),
    .DO<7>(DO[7]),  .DO<6>(DO[6]),  .DO<5>(DO[5]),  .DO<4>(DO[4]),
    .DO<3>(DO[3]),  .DO<2>(DO[2]),  .DO<1>(DO[1]),  .DO<0>(DO[0]),

    .DI<31>(DI[31]), .DI<30>(DI[30]), .DI<29>(DI[29]), .DI<28>(DI[28]),
    .DI<27>(DI[27]), .DI<26>(DI[26]), .DI<25>(DI[25]), .DI<24>(DI[24]),
    .DI<23>(DI[23]), .DI<22>(DI[22]), .DI<21>(DI[21]), .DI<20>(DI[20]),
    .DI<19>(DI[19]), .DI<18>(DI[18]), .DI<17>(DI[17]), .DI<16>(DI[16]),
    .DI<15>(DI[15]), .DI<14>(DI[14]), .DI<13>(DI[13]), .DI<12>(DI[12]),
    .DI<11>(DI[11]), .DI<10>(DI[10]), .DI<9>(DI[9]),  .DI<8>(DI[8]),
    .DI<7>(DI[7]),  .DI<6>(DI[6]),  .DI<5>(DI[5]),  .DI<4>(DI[4]),
    .DI<3>(DI[3]),  .DI<2>(DI[2]),  .DI<1>(DI[1]),  .DI<0>(DI[0]),

    .AD<31>(AD[31]), .AD<30>(AD[30]), .AD<29>(AD[29]), .AD<28>(AD[28]),
    .AD<27>(AD[27]), .AD<26>(AD[26]), .AD<25>(AD[25]), .AD<24>(AD[24]),
    .AD<23>(AD[23]), .AD<22>(AD[22]), .AD<21>(AD[21]), .AD<20>(AD[20]),
    .AD<19>(AD[19]), .AD<18>(AD[18]), .AD<17>(AD[17]), .AD<16>(AD[16]),
    .AD<15>(AD[15]), .AD<14>(AD[14]), .AD<13>(AD[13]), .AD<12>(AD[12]),
    .AD<11>(AD[11]), .AD<10>(AD[10]), .AD<9>(AD[9]),  .AD<8>(AD[8]),
    .AD<7>(AD[7]),  .AD<6>(AD[6]),  .AD<5>(AD[5]),  .AD<4>(AD[4]),
    .AD<3>(AD[3]),  .AD<2>(AD[2]),  .AD<1>(AD[1]),  .AD<0>(AD[0]),

    .SEL<3>(SEL[3]), .SEL<2>(SEL[2]), .SEL<1>(SEL[1]), .SEL<0>(SEL[0]),

    .CLKin(CLKin),
    .RSTin(RSTin),
    .EN(EN),
    .R_WB(R_WB),
    .func_ack(func_ack),

    .TM(TM),
    .SM(SM),
    .ScanInCC(ScanInCC),
    .ScanInDL(ScanInDL),
    .ScanInDR(ScanInDR),
    .ScanOutCC(ScanOutCC),

    .VDD(VDD),
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
