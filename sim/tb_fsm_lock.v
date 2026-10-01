`timescale 1ns / 1ps

module tb_fsm_lock;
    reg clk=0, rst=1;
    reg [3:0] digit_in=0;
    reg digit_valid=0;
    reg [15:0] vio_golden=0;
    reg vio_write=0;
    reg ms_tick=0;
    wire led_green, led_red;
    wire [15:0] shift_reg_out;
    wire [2:0] digit_count_out, state_out;
    wire [15:0] golden_code_out;
    wire unlock_running_out, unlock_done_out, lockout_running_out, lockout_done_out;
    wire [15:0] unlock_elapsed_ms, lockout_elapsed_ms;
    localparam S_IDLE=3'd0, S_INPUT=3'd1, S_CHECK=3'd2, S_UNLOCK=3'd3, S_LOCKOUT=3'd4;

    fsm_lock #(.UNLOCK_MS(4), .LOCKOUT_MS(5)) dut (
        .clk(clk), .rst(rst), .digit_in(digit_in), .digit_valid(digit_valid),
        .vio_golden(vio_golden), .vio_write(vio_write), .ms_tick(ms_tick),
        .led_green(led_green), .led_red(led_red), .shift_reg_out(shift_reg_out),
        .digit_count_out(digit_count_out), .state_out(state_out),
        .golden_code_out(golden_code_out), .unlock_running_out(unlock_running_out),
        .unlock_done_out(unlock_done_out), .unlock_elapsed_ms(unlock_elapsed_ms),
        .lockout_running_out(lockout_running_out), .lockout_done_out(lockout_done_out),
        .lockout_elapsed_ms(lockout_elapsed_ms)
    );

    always #5 clk = ~clk;

    task pulse_digit(input [3:0] d);
      begin
        @(negedge clk); digit_in=d; digit_valid=1'b1;
        @(negedge clk); digit_valid=1'b0;
      end
    endtask

    task pulse_ms_tick;
      begin
        @(negedge clk); ms_tick=1'b1;
        @(negedge clk); ms_tick=1'b0;
      end
    endtask

    initial begin
      repeat(2) @(posedge clk);
      rst=0;

      @(negedge clk); vio_golden=16'h1234; vio_write=1'b1;
      @(negedge clk); vio_write=1'b0;

      pulse_digit(1); pulse_digit(2); pulse_digit(3); pulse_digit(4);
      wait(state_out==S_CHECK);
      @(posedge clk); #1;
      if(state_out!==S_UNLOCK) $fatal(1,"Correct code did not enter UNLOCK");
      if(shift_reg_out!==16'h1234) $fatal(1,"Entered code mismatch: %h",shift_reg_out);
      repeat(4) pulse_ms_tick;
      wait(state_out==S_IDLE);
      if(shift_reg_out!==16'h0000) $fatal(1,"Shift register not cleared after UNLOCK");

      pulse_digit(1); pulse_digit(2); pulse_digit(3); pulse_digit(5);
      wait(state_out==S_CHECK);
      @(posedge clk); #1;
      if(state_out!==S_LOCKOUT) $fatal(1,"Incorrect code did not enter LOCKOUT");
      repeat(5) pulse_ms_tick;
      wait(state_out==S_IDLE);
      if(shift_reg_out!==16'h0000) $fatal(1,"Shift register not cleared after LOCKOUT");

      pulse_digit(10);
      if(digit_count_out!==3'd0) $fatal(1,"Invalid digit was accepted");

      $display("All fsm_lock tests passed.");
      $finish;
    end
endmodule
