`ifdef USE_POWER_PINS
    `define USE_PG_PIN
`endif

// ============================================================================
// Neuromorphic_X1_wb_wrapper
// Pass-through wrapper that instantiates Neuromorphic_X1_wb with identical I/O.
// ============================================================================
module Neuromorphic_X1_wb_wrapper #(parameter WIDTH = 12) (
    `ifdef USE_POWER_PINS
      inout VPWR,
      inout VDDA,
      inout VSS,
   `endif
    // Clocks / resets
    input         user_clk,       // user clock
    input         user_rst,       // user reset
    input         wb_clk_i,       // Wishbone clock
    input         wb_rst_i,       // Wishbone reset (Active High)

    // Wishbone bus
    input         wbs_stb_i,      // Wishbone strobe
    input         wbs_cyc_i,      // Wishbone cycle indicator
    input         wbs_we_i,       // Wishbone write enable: 1=write, 0=read
    input  [3:0]  wbs_sel_i,      // Wishbone byte select (must be 4'hF for 32-bit op)
    input  [31:0] wbs_dat_i,      // Wishbone write data (becomes DI to core)
    input  [31:0] wbs_adr_i,      // Wishbone address
    output [31:0] wbs_dat_o,      // Wishbone read data output (driven by DO from core)
    output        wbs_ack_o,      // Wishbone acknowledge output (core_ack from core)

    // Scan/Test Pins
    input         ScanInCC,       // Scan enable (as provided)
    input         ScanInDL,       // Data scan chain input (user_clk domain)
    input         ScanInDR,       // Data scan chain input (wb_clk domain)
    input         TM,             // Test mode
    output        ScanOutCC,      // Data scan chain output

    // Analog / supply rails & references
    input         Iref,           // 100 µA current reference
    input         Vcc_read,       // 0.3 V read rail
    input         Vcomp,          // 0.6 V comparator bias
    input         Bias_comp2,     // 0.6 V comparator bias
    input         Vcc_wl_read,    // 0.7 V wordline read rail
    input         Vcc_wl_set,     // 1.8 V wordline set rail
    input         Vbias,          // 1.8 V analog bias
    input         Vcc_wl_reset,   // 2.6 V wordline reset rail
    input         Vcc_set,        // 3.3 V array set rail
    input         Vcc_reset,      // 3.3 V array reset rail
    input         Vcc_L,          // 5 V level shifter supply
    input         Vcc_Body        // 5 V body-bias supply
);

    // ------------------------------------------------------------------------
    // Core instantiation (direct 1:1 mapping)
    // ------------------------------------------------------------------------
    Neuromorphic_X1_wb i_core (
    `ifdef USE_PG_PIN
      .VDDC(VPWR),
      .VDDA(VDDA),
      .VSS(VSS),
    
    `endif
        // Clocks / resets
        .user_clk      ( user_clk       ),
        .user_rst      ( user_rst       ),
        .wb_clk_i      ( wb_clk_i       ),
        .wb_rst_i      ( wb_rst_i       ),

        // Wishbone
        .wbs_stb_i     ( wbs_stb_i      ),
        .wbs_cyc_i     ( wbs_cyc_i      ),
        .wbs_we_i      ( wbs_we_i       ),
        .wbs_sel_i     ( wbs_sel_i      ),
        .wbs_dat_i     ( wbs_dat_i      ),
        .wbs_adr_i     ( wbs_adr_i      ),
        .wbs_dat_o     ( wbs_dat_o      ),
        .wbs_ack_o     ( wbs_ack_o      ),

        // Scan/Test
        .ScanInCC      ( ScanInCC       ),
        .ScanInDL      ( ScanInDL       ),
        .ScanInDR      ( ScanInDR       ),
        .TM            ( TM             ),
        .ScanOutCC     ( ScanOutCC      ),

        // Analog / supplies
        .Iref          ( Iref           ),
        .Vcc_read      ( Vcc_read       ),
        .Vcomp         ( Vcomp          ),
        .Bias_comp2    ( Bias_comp2     ),
        .Vcc_wl_read   ( Vcc_wl_read    ),
        .Vcc_wl_set    ( Vcc_wl_set     ),
        .Vbias         ( Vbias          ),
        .Vcc_wl_reset  ( Vcc_wl_reset   ),
        .Vcc_set       ( Vcc_set        ),
        .Vcc_reset     ( Vcc_reset      ),
        .Vcc_L         ( Vcc_L          ),
        .Vcc_Body      ( Vcc_Body       )
    );

endmodule

