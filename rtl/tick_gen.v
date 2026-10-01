module tick_gen #(
    parameter integer CLK_FREQ_HZ   = 100_000_000,
    parameter integer MS_TICK_COUNT = CLK_FREQ_HZ / 1000
) (
    input  wire clk,
    input  wire rst,
    output reg  ms_tick
);

    localparam integer COUNTER_WIDTH =
        (MS_TICK_COUNT < 2) ? 1 : $clog2(MS_TICK_COUNT);

    reg [COUNTER_WIDTH-1:0] cnt;

    always @(posedge clk) begin
        if (rst) begin
            cnt     <= 0;
            ms_tick <= 1'b0;
        end else if (cnt == MS_TICK_COUNT - 1) begin
            cnt     <= 0;
            ms_tick <= 1'b1;
        end else begin
            cnt     <= cnt + 1'b1;
            ms_tick <= 1'b0;
        end
    end

endmodule
