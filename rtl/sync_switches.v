module sync_switches (
    input  wire       clk,
    input  wire       rst,
    input  wire [3:0] sw_digit_raw,
    input  wire       enter_pulse,
    output reg  [3:0] digit,
    output reg        digit_valid
);

    (* ASYNC_REG = "TRUE" *) reg [3:0] sw_sync_0;
    (* ASYNC_REG = "TRUE" *) reg [3:0] sw_sync_1;

    always @(posedge clk) begin
        if (rst) begin
            sw_sync_0   <= 4'b0;
            sw_sync_1   <= 4'b0;
            digit       <= 4'b0;
            digit_valid <= 1'b0;
        end else begin
            sw_sync_0 <= sw_digit_raw;
            sw_sync_1 <= sw_sync_0;
            digit_valid <= 1'b0;

            if (enter_pulse && (sw_sync_1 <= 4'd9)) begin
                digit       <= sw_sync_1;
                digit_valid <= 1'b1;
            end
        end
    end

endmodule
