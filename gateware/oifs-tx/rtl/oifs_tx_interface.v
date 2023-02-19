//
//
//


`default_nettype    none


module oifs_tx_interface #(
    parameter   DATA_W = 8
)(
    input   wire                    i_clk,
    input   wire                    i_arst,
    // valid-ready interface
    input   wire                    i_valid,
    input   wire [DATA_W - 1 : 0]   i_data,
    input   wire                    i_channel,
    output  wire                    o_ready,
    // tick
    input   wire                    i_tick,
    // opto tx interface
    input   wire                    i_fscts,
    output  wire                    o_fsclk,
    output  wire                    o_fsdi
);
    //
    // CDC signals
    //
    localparam  DFF_W = 2;

    wire                    w_fscts;
    reg     [DFF_W - 1 : 0] r_fscts_sync;

    always @ (posedge i_clk)
        r_fscts_sync <= {r_fscts_sync[DFF_W - 2 : 0], i_fscts};

    assign w_fscts = r_fscts_sync[DFF_W - 1];

    //
    // r_data_status
    //
    // r_data_status decides the valid-ready signals and
    // if r_status FSM starts
    //
    reg     r_data_filled;
    reg     r_data_filled_next;

    wire    w_data_done;
    wire    w_status_done;

    always @ (posedge i_clk, posedge i_arst)
        if (i_arst)
            r_data_filled <= 1'b0;
        else
            r_data_filled <= r_data_filled_next;

    always @(*) begin
        r_data_filled_next = r_data_filled;

        // if the tx data has been filled
        if (r_data_filled) begin
            // and the data transmission has been done
            if (w_data_done)
                r_data_filled_next = 1'b0;
        end
        // or if the tx data is empty
        else begin
            // and upstream module's data is ready
            if (i_valid)
                r_data_filled_next = 1'b1;
        end
    end

    assign w_data_done = w_status_done & i_tick;

    //
    // r_data
    //
    // r_data keeps the data to be transmitted
    //
    localparam  TX_DATA_W = DATA_W + 3;

    reg     [TX_DATA_W - 1 : 0] r_data;
    reg     [TX_DATA_W - 1 : 0] w_data_next;

    wire                        w_data_tick;
    wire                        w_data_load;
    wire                        w_status_tick;

    always @ (posedge i_clk, posedge i_arst)
        if (i_arst)
            r_data <= {TX_DATA_W{1'b1}};
        else
            r_data <= w_data_next;

    always @(*) begin
        w_data_next = r_data;

        if (w_data_load)
            w_data_next = {i_channel, i_data, 2'b01};
        else
            if (w_data_tick)
                w_data_next = {1'b1, r_data[TX_DATA_W - 1 : 1]};
    end

    // w_data_load indicates if r_data could be filled safely
    assign w_data_load = o_ready & i_valid;
    assign w_data_tick = w_status_tick | w_status_start;

    //
    // r_status
    //
    // r_status controls TX FSM
    //
    localparam  STATUS_MAX  = 11;
    localparam  STATUS_W    = $clog2(STATUS_MAX);

    reg     [STATUS_W - 1 : 0]  r_status;
    reg     [STATUS_W - 1 : 0]  w_status_next;

    wire                        w_status_start;
    wire                        w_status_idle;

    assign w_status_idle = (r_status == {STATUS_W{1'b0}});
    assign w_status_done = (r_status == (STATUS_MAX[STATUS_W - 1 : 0] - 1'b1));
    assign w_status_tick = i_tick & ~w_status_idle;

    always @ (posedge i_clk, posedge i_arst)
        if (i_arst)
            r_status <= {STATUS_W{1'b0}};
        else
            r_status <= w_status_next;

    always @(*) begin
        w_status_next = r_status;

        if (w_status_start)
            w_status_next = {{STATUS_W-1{1'b0}}, 1'b1};
        else
            if (w_status_tick)
                if (w_status_done)
                    w_status_next = {STATUS_W{1'b0}};
                else
                    w_status_next = r_status + 1'b1;
    end

    // FSM begins counting when FSM is idle
    assign w_status_start = w_status_idle &
                            // r_data is filled
                            r_data_filled &
                            // i_fstcs is ready to receive data
                            w_fscts &
                            // to sync with o_fsclk signal
                            i_tick;

    //
    // output signals
    //
    // r_data is ready when r_data_filled is 0
    assign o_ready = ~r_data_filled;

    assign o_fsdi = r_data[0];

endmodule
