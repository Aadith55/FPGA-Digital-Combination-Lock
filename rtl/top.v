\`timescale 1ns / 1ps

module top #(
    parameter integer CLK_FREQ_HZ   = 100_000_000,
    parameter integer MS_TICK_COUNT = CLK_FREQ_HZ / 1000,
    parameter integer UNLOCK_MS     = 2000,
    parameter integer LOCKOUT_MS    = 5000
) (
    input  wire       clk,
    input  wire       btn_reset,
    input  wire       btn_enter,
    input  wire [3:0] sw,
    output wire       led_green,
    output wire       led_red
);

    (* ASYNC_REG = "TRUE" *) reg btn_reset_sync0;
    (* ASYNC_REG = "TRUE" *) reg btn_reset_sync1;
    wire rst_sync;

    always @(posedge clk) begin
        btn_reset_sync0 <= btn_reset;
        btn_reset_sync1 <= btn_reset_sync0;
    end

    assign rst_sync = btn_reset_sync1;

    (* mark_debug = "true" *) wire        ms_tick;
    (* mark_debug = "true" *) wire        enter_pulse;
    (* mark_debug = "true" *) wire [3:0]  digit;
    (* mark_debug = "true" *) wire        digit_valid;
    (* mark_debug = "true" *) wire [15:0] vio_golden;
    (* mark_debug = "true" *) wire        vio_write;
    (* mark_debug = "true" *) wire [15:0] shift_out;
    (* mark_debug = "true" *) wire [2:0]  digit_count_out;
    (* mark_debug = "true" *) wire [2:0]  state_out;
    (* mark_debug = "true" *) wire [15:0] golden_out;
    (* mark_debug = "true" *) wire [15:0] entered_code;
    (* mark_debug = "true" *) wire        unlock_running;
    (* mark_debug = "true" *) wire        unlock_done;
    (* mark_debug = "true" *) wire [15:0] unlock_elapsed_ms;
    (* mark_debug = "true" *) wire        lockout_running;
    (* mark_debug = "true" *) wire        lockout_done;
    (* mark_debug = "true" *) wire [15:0] lockout_elapsed_ms;

    tick_gen #(
        .CLK_FREQ_HZ(CLK_FREQ_HZ),
        .MS_TICK_COUNT(MS_TICK_COUNT)
    ) msgen (
        .clk(clk),
        .rst(rst_sync),
        .ms_tick(ms_tick)
    );

    debounce_enter #(
        .STABLE_MS(20)
    ) d_enter (
        .clk(clk),
        .rst(rst_sync),
        .ms_tick(ms_tick),
        .btn_async(btn_enter),
        .enter_pulse(enter_pulse)
    );

    sync_switches fe (
        .clk(clk),
        .rst(rst_sync),
        .sw_digit_raw(sw),
        .enter_pulse(enter_pulse),
        .digit(digit),
        .digit_valid(digit_valid)
    );

    LockVIO lock_vio_inst (
        .clk(clk),
        .vio_golden(vio_golden),
        .vio_write(vio_write)
    );

    fsm_lock #(
        .UNLOCK_MS(UNLOCK_MS),
        .LOCKOUT_MS(LOCKOUT_MS)
    ) fsm (
        .clk(clk),
        .rst(rst_sync),
        .digit_in(digit),
        .digit_valid(digit_valid),
        .vio_golden(vio_golden),
        .vio_write(vio_write),
        .ms_tick(ms_tick),
        .led_green(led_green),
        .led_red(led_red),
        .shift_reg_out(shift_out),
        .digit_count_out(digit_count_out),
        .state_out(state_out),
        .golden_code_out(golden_out),
        .unlock_running_out(unlock_running),
        .unlock_done_out(unlock_done),
        .unlock_elapsed_ms(unlock_elapsed_ms),
        .lockout_running_out(lockout_running),
        .lockout_done_out(lockout_done),
        .lockout_elapsed_ms(lockout_elapsed_ms)
    );

    assign entered_code = shift_out;

    ila_0 ila_inst (
        .clk(clk),
        .probe0(entered_code),
        .probe1(digit_count_out),
        .probe2(state_out),
        .probe3(golden_out),
        .probe4(vio_write),
        .probe5(enter_pulse),
        .probe6(digit),
        .probe7(unlock_running),
        .probe8(unlock_done),
        .probe9(unlock_elapsed_ms),
        .probe10(lockout_running),
        .probe11(lockout_done),
        .probe12(lockout_elapsed_ms),
        .probe13(led_green),
        .probe14(led_red)
    );

endmodule
