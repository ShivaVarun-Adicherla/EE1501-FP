
`timescale 1s / 1ms
// We will not enable the timer and increment day 2000 times to check if all the dates match to actual dates.
module checking_dates_tb;
  reg clk, change_mode, increment, decrement, select, reset, togglestart, startstop_alarm_timer;
  wire [5:0][3:0] hhmmss;
  wire [7:0][3:0] ddmmyyyy;
  wire [2:0][7:0] weekascii;
  wire AM_mode, PM_Mode, timer_buzzer, alarm_buzzer;
  top_module DUT (

      clk,
      change_mode,
      increment,  //Increases the selected parameter by 1.(second,minute,hour,day)
      decrement,  //Decreases the selected parameter by 1.(second,minute,hour,day)
      select,  //To select which parameter we are changing.(Advised to use when clock is stopped, or for timer/alarm)
      reset,  //Resets everything to default values(MUST BE USED ON STARTUP)
      togglestart,  //Toggles if clock is running or not.
      hhmmss,
      ddmmyyyy,
      weekascii,
      startstop_alarm_timer,
      AM_mode,
      PM_mode,
      timer_buzzer,
      alarm_buzzer
  );

  always #0.5 clk = ~clk;

  initial begin
    $dumpfile("simout.vcd");
    $dumpvars;
    clk = 0;
    change_mode = 0;
    increment = 0;
    decrement = 0;
    select = 0;
    reset = 0;
    togglestart = 0;
    #1;
    reset = 1;
    #1;
    reset = 0;
    #1;
    repeat (3) begin
      select = 1;
      #1;
      select = 0;
      #1;
    end
    repeat (2000) begin
      increment = 1;
      #0.5;
      increment = 0;
      #0.5;
    end
    $finish;
  end
endmodule
