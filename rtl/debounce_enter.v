module debounce_enter #(
    parameter integer STABLE_MS = 20
) (
    input  wire clk,
    input  wire rst,
    input  wire ms_tick,
    input  wire btn_async,
    output reg  enter_pulse
);

    (* ASYNC_REG = "TRUE" *) reg btn_sync_0;
    (* ASYNC_REG = "TRUE" *) reg btn_sync_1;

    always @(posedge clk) begin
        if (rst) begin
            btn_sync_0 <= 1'b0;
            btn_sync_1 <= 1'b0;
        end else begin
            btn_sync_0 <= btn_async;
            btn_sync_1 <= btn_sync_0;
        end
    end

    localparam integer CNT_WIDTH =
        (STABLE_MS < 2) ? 1 : $clog2(STABLE_MS + 1);

    reg [CNT_WIDTH-1:0] stable_cnt;
    reg debounced_state;

    always @(posedge clk) begin
        if (rst) begin
            stable_cnt       <= 0;
            debounced_state  <= 1'b0;
            enter_pulse      <= 1'b0;
        end else begin
            enter_pulse <= 1'b0;

            if (ms_tick) begin
                if (btn_sync_1 == debounced_state) begin
                    stable_cnt <= 0;
                end else if (stable_cnt == STABLE_MS - 1) begin
                    if (!debounced_state && btn_sync_1)
                        enter_pulse <= 1'b1;

                    debounced_state <= btn_sync_1;
                    stable_cnt      <= 0;
                end else begin
                    stable_cnt <= stable_cnt + 1'b1;
                end
            end
        end
    end

endmodule
