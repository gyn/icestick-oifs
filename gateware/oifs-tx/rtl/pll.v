/**
 * PLL configuration
 *
 * This Verilog module was generated automatically
 * using the icepll tool from the IceStorm project.
 * Use at your own risk.
 *
 * Given input frequency:        12.000 MHz
 * Requested output frequency:   99.000 MHz
 * Achieved output frequency:    99.000 MHz
 */

module pll (
    input  wire		i_clk_ref,
    output wire		o_clk,
    output wire   	o_locked
);

    SB_PLL40_CORE #(
        .FEEDBACK_PATH  ( "SIMPLE"      ),
        .DIVR           ( 4'b0000       ),   	// DIVR =  0
        .DIVF           ( 7'b1000001    ),      // DIVF = 65
        .DIVQ           ( 3'b011        ),      // DIVQ =  3
        .FILTER_RANGE   ( 3'b001        )       // FILTER_RANGE = 1
    ) u_pll_u0 (
        .LOCK           ( o_locked      ),
        .RESETB         ( 1'b1          ),
        .BYPASS         ( 1'b0          ),
        .REFERENCECLK   ( i_clk_ref     ),
        .PLLOUTGLOBAL   ( o_clk       	)
    );

endmodule
