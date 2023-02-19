//
//
//


`default_nettype    none


module oifs_tx_controller_sim #(
    parameter   DATA_W = 8,
    parameter   DELAY  = 99
)(
    input   wire            i_clk,
    input   wire            i_arst,
    // oifs tx interface
    input   wire            i_fscts,
    output  wire            o_fsclk,
    output  wire            o_fsdi
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

    wire                        w_tick;
    wire                        w_valid;
    wire    [DATA_W - 1 : 0]    w_data;
    wire                        w_channel;
    wire                        w_ready;

    oifs_tx_interface
    u_oifs_tx_interface_u0 (
        .i_clk      ( i_clk     ),
        .i_arst     ( i_arst    ),
        .i_valid    ( w_valid   ),
        .i_data     ( w_data    ),
        .i_channel  ( w_channel ),
        .o_ready    ( w_ready   ),
        .i_tick     ( w_tick    ),
        .i_fscts    ( i_fscts   ),
        .o_fsclk    ( o_fsclk   ),
        .o_fsdi     ( o_fsdi    )
    );

    assign w_tick = r_counter;

    oifs_tx_controller #(
        .DELAY      ( DELAY     )
    ) u_oifs_tx_controller_u0 (
        .i_clk      ( i_clk     ),
        .i_arst     ( i_arst    ),
        .o_valid    ( w_valid   ),
        .o_data     ( w_data    ),
        .o_channel  ( w_channel ),
        .i_ready    ( w_ready   )
    );

    assign o_fsclk = r_counter;

endmodule
