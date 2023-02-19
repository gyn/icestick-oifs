//
//
//


`default_nettype    none


module oifs_tx_interface_sim #(
    parameter   DATA_W = 8
)(
    input   wire                    i_clk,
    input   wire                    i_arst,
    // valid-ready interface
    input   wire                    i_valid,
    input   wire [DATA_W - 1 : 0]   i_data,
    input   wire                    i_channel,
    output  wire                    o_ready,
    // oifs tx interface
    input   wire                    i_fscts,
    output  wire                    o_fsclk,
    output  wire                    o_fsdi
);

    //
    // Assuming i_clk is a bit less than 100MHz, a DFF reversing its output
    // as input is used to produce a clock around 50MHz.
    //
    reg     r_counter;

    always @ (posedge i_clk, posedge i_arst)
        if (i_arst)
            r_counter <= 1'b0;
        else
            r_counter <= ~r_counter;

    reg     w_tick;

    oifs_tx_interface
    u_oifs_tx_interface_u0 (
        .i_clk      ( i_clk     ),
        .i_arst     ( i_arst    ),
        .i_valid    ( i_valid   ),
        .i_data     ( i_data    ),
        .i_channel  ( i_channel ),
        .o_ready    ( o_ready   ),
        .i_tick     ( w_tick    ),
        .i_fscts    ( i_fscts   ),
        .o_fsclk    ( o_fsclk   ),
        .o_fsdi     ( o_fsdi    )
    );

    assign w_tick = r_counter;

    assign o_fsclk = r_counter;

endmodule
