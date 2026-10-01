module fsm_lock #(
    parameter integer UNLOCK_MS  = 2000,
    parameter integer LOCKOUT_MS = 5000
) (
    input wire        clk,
    input wire        rst,
    input wire [3:0]  digit_in,
    input wire        digit_valid,
    input wire [15:0] vio_golden,
    input wire        vio_write,
    input wire        ms_tick,

    output reg        led_green,
    output reg        led_red,
    output wire [15:0] shift_reg_out,
    output wire [2:0]  digit_count_out,
    output wire [2:0]  state_out,
    output wire [15:0] golden_code_out,

    output wire        unlock_running_out,
    output wire        unlock_done_out,
    output reg  [15:0] unlock_elapsed_ms,

    output wire        lockout_running_out,
    output wire        lockout_done_out,
    output reg  [15:0] lockout_elapsed_ms
);

    localparam S_IDLE    = 3'd0;
    localparam S_INPUT   = 3'd1;
    localparam S_CHECK   = 3'd2;
    localparam S_UNLOCK  = 3'd3;
    localparam S_LOCKOUT = 3'd4;

    reg [2:0] state;
    reg [2:0] next_state;

    wire [15:0] shift_reg_w;
    wire [2:0]  digit_count_w;

    wire unlock_running;
    wire unlock_done;
    wire lockout_running;
    wire lockout_done;

    reg start_unlock_timer;
    reg start_lockout_timer;

    wire clear_shift;
    wire digit_valid_gated;

    assign digit_valid_gated =
        digit_valid && !((state == S_UNLOCK) || (state == S_LOCKOUT));

    reg [15:0] golden_code;

    wire vio_golden_valid_nibbles;

    assign vio_golden_valid_nibbles =
        (vio_golden[15:12] <= 4'd9) &&
        (vio_golden[11:8]  <= 4'd9) &&
        (vio_golden[7:4]   <= 4'd9) &&
        (vio_golden[3:0]   <= 4'd9);

    always @(posedge clk) begin
        if (rst) begin
            golden_code <= 16'h0000;
        end else if (vio_write &&
                     (state == S_IDLE) &&
                     vio_golden_valid_nibbles) begin
            golden_code <= vio_golden;
        end
    end

    timer #(
        .DURATION_MS(UNLOCK_MS)
    ) unlock_timer (
        .clk(clk),
        .rst(rst),
        .ms_tick(ms_tick),
        .start(start_unlock_timer),
        .running(unlock_running),
        .done(unlock_done)
    );

    timer #(
        .DURATION_MS(LOCKOUT_MS)
    ) lockout_timer (
        .clk(clk),
        .rst(rst),
        .ms_tick(ms_tick),
        .start(start_lockout_timer),
        .running(lockout_running),
        .done(lockout_done)
    );

    assign unlock_running_out  = unlock_running;
    assign unlock_done_out     = unlock_done;
    assign lockout_running_out = lockout_running;
    assign lockout_done_out    = lockout_done;

    shift_reg shift_inst (
        .clk(clk),
        .rst(rst),
        .clear(clear_shift),
        .new_digit(digit_in),
        .new_digit_valid(digit_valid_gated),
        .code_out(shift_reg_w),
        .digit_count(digit_count_w)
    );

    always @(posedge clk) begin
        if (rst)
            state <= S_IDLE;
        else
            state <= next_state;
    end

    always @(*) begin
        next_state          = state;
        start_unlock_timer  = 1'b0;
        start_lockout_timer = 1'b0;

        case (state)
            S_IDLE: begin
                if (digit_valid)
                    next_state = S_INPUT;
            end

            S_INPUT: begin
                if (digit_count_w == 3'd4)
                    next_state = S_CHECK;
            end

            S_CHECK: begin
                if (shift_reg_w == golden_code) begin
                    next_state         = S_UNLOCK;
                    start_unlock_timer = 1'b1;
                end else begin
                    next_state          = S_LOCKOUT;
                    start_lockout_timer = 1'b1;
                end
            end

            S_UNLOCK: begin
                if (unlock_done)
                    next_state = S_IDLE;
            end

            S_LOCKOUT: begin
                if (lockout_done)
                    next_state = S_IDLE;
            end

            default: begin
                next_state = S_IDLE;
            end
        endcase
    end

    // Clear on the same terminal clock boundary.
    assign clear_shift =
           ((state == S_UNLOCK)  && unlock_done)
        || ((state == S_LOCKOUT) && lockout_done);

    always @(posedge clk) begin
        if (rst) begin
            led_green <= 1'b0;
            led_red   <= 1'b0;
        end else begin
            led_green <= 1'b0;
            led_red   <= 1'b0;

            case (state)
                S_UNLOCK:  led_green <= 1'b1;
                S_LOCKOUT: led_red   <= 1'b1;
                default: begin end
            endcase
        end
    end

    always @(posedge clk) begin
        if (rst) begin
            unlock_elapsed_ms  <= 16'd0;
            lockout_elapsed_ms <= 16'd0;
        end else begin
            if (unlock_running) begin
                if (ms_tick)
                    unlock_elapsed_ms <= unlock_elapsed_ms + 16'd1;
            end else begin
                unlock_elapsed_ms <= 16'd0;
            end

            if (lockout_running) begin
                if (ms_tick)
                    lockout_elapsed_ms <= lockout_elapsed_ms + 16'd1;
            end else begin
                lockout_elapsed_ms <= 16'd0;
            end
        end
    end

    assign shift_reg_out   = shift_reg_w;
    assign digit_count_out = digit_count_w;
    assign state_out       = state;
    assign golden_code_out = golden_code;

endmodule
