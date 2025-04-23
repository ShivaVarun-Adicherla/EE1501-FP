`timescale 1s / 1ms
module top_module_tb;
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
      startstop_alarm_timer,
      hhmmss,
      ddmmyyyy,
      weekascii,
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
    startstop_alarm_timer = 0;
    #1;
    reset = 1;
    #1;
    reset = 0;
    #1;
    togglestart = 1;
    #1 togglestart = 0;
    #100;
    change_mode = 1;
    #1 change_mode = 0;
    #1 select = 1;
    #1 select = 0;
    repeat (5) begin
      increment = 1;
      #1;
      increment = 0;
      #1;
    end
    #1 startstop_alarm_timer = 1;
    #1 startstop_alarm_timer = 0;
    #4 change_mode = 1;
    #1 change_mode = 0;
    #1 change_mode = 1;
    #1 change_mode = 0;
    #4 togglestart = 1;
    #1 togglestart = 0;
    #1 change_mode = 1;
    #1 change_mode = 0;
    #1 change_mode = 1;
    #1 change_mode = 0;
    #1 change_mode = 1;
    #1 change_mode = 0;
    #1 togglestart = 1;
    #1 togglestart = 0;
    #400;
    #1 startstop_alarm_timer = 1;
    #1 startstop_alarm_timer = 0;
    $finish;
  end
endmodule
