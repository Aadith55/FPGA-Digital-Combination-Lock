module timer #(
    parameter integer DURATION_MS = 2000
) (
    input wire clk,
    input wire rst,
    input wire ms_tick,
    input wire start,
    output reg running,
    output reg done
);

    localparam integer WIDTH =
        (DURATION_MS < 2) ? 1 : $clog2(DURATION_MS + 1);

    reg [WIDTH-1:0] cnt;

    always @(posedge clk) begin
        if (rst) begin
            cnt     <= 0;
            running <= 1'b0;
            done    <= 1'b0;
        end else begin
            done <= 1'b0;

            if (!running) begin
                if (start) begin
                    running <= 1'b1;
                    cnt     <= 0;
                end
            end else if (ms_tick) begin
                if (cnt == DURATION_MS - 1) begin
                    running <= 1'b0;
                    done    <= 1'b1;
                    cnt     <= 0;
                end else begin
                    cnt <= cnt + 1'b1;
                end
            end
        end
    end

endmodule
