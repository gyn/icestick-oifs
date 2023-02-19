//
//
//


`default_nettype    none


module oifs_top (
    input   wire            i_clk,
    input   wire            i_fsdo,
    input   wire            i_fscts,
    output  wire            o_fsclk,
    output  wire            o_fsdi,
    // for debug only
    output  wire [3 : 0]    o_dbg,
    output  wire [4 : 0]    o_led
);
    wire                    w_sys_clk;
    wire                    w_sys_arst;
    wire                    w_tick;
    wire                    w_pll_locked;

    pll
    u_pll_u0 (
        .i_clk_ref  ( i_clk         ),
        .o_clk      ( w_sys_clk     ),
        .o_locked   ( w_pll_locked  )
    );

    oifs
    u_oifs_u0 (
        .i_clk      ( w_sys_clk     ),
        .i_arst     ( w_sys_arst    ),
        .o_tick     ( w_tick        ),
        .i_fsdo     ( i_fsdo        ),
        .i_fscts    ( i_fscts       ),
        .o_fsclk    ( o_fsclk       ),
        .o_fsdi     ( o_fsdi        )
    );

    assign w_sys_arst = ~w_pll_locked;

    assign o_dbg = {i_fsdo, i_fscts, o_fsclk, o_fsdi};

    reg     [4 : 0]     r_led;

    always @ (posedge w_sys_clk, posedge w_sys_arst)
        if (w_sys_arst)
            r_led <= 5'b00001;
        else
            if (w_tick)
                r_led <= {r_led[3:0], ~r_led[4]};

    assign o_led = r_led;

endmodule
