//
//
//


`default_nettype    none

module oifs_tx_controller #(
    parameter   DATA_W  = 8,
    parameter   MODE    = "FIXED_PEROID",    // "FULL_SPEED"
    parameter   DELAY   = 99_000_000
)(
    input   wire                    i_clk,
    input   wire                    i_arst,
    output  wire                    o_valid,
    output  wire [DATA_W - 1 : 0]   o_data,
    output  wire                    o_channel,
    input   wire                    i_ready
);
    wire                        w_data_en;
    wire                        w_data_valid;

    reg     [DATA_W - 1 : 0]    r_data;
    wire    [DATA_W - 1 : 0]    w_data_next;

    always @ (posedge i_clk, posedge i_arst)
        if (i_arst)
            r_data <= {DATA_W{1'b0}};
        else
            r_data <= w_data_next;

    assign w_data_next = w_data_en ? r_data + 1'b1 : r_data;

    generate
        if (MODE == "FULL_SPEED") begin
            reg     r_ready;

            always @ (posedge i_clk)
                r_ready <= i_ready;

            assign w_data_en = r_ready & ~i_ready;
            assign w_data_valid = 1'b1;
        end
        else if (MODE == "FIXED_PEROID") begin
            localparam  WIDTH       = $clog2(DELAY);

            reg     [WIDTH - 1 : 0] r_counter;
            wire    [WIDTH - 1 : 0] w_counter_next;

            wire                    w_tick;

            always @ (posedge i_clk, posedge i_arst)
                if (i_arst)
                    r_counter <= {WIDTH{1'b0}};
                else
                    r_counter <= w_counter_next;

            assign w_tick         = (r_counter == (DELAY[WIDTH - 1 : 0] - 1'b1));
            assign w_counter_next = w_tick ? {WIDTH{1'b0}} : (r_counter + 1'b1);

            assign w_data_en = w_tick;
            assign w_data_valid = w_tick;
        end
    endgenerate

    assign o_channel = 1'b1;
    assign o_data = r_data;
    assign o_valid = w_data_valid;

endmodule
