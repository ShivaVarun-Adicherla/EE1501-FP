`timescale 1s / 1ms
module top_module_tb;
  reg clk;
  always #0.5 clk = ~clk;
  reg change_mode;
  reg increment;
  reg decrement;
  reg select;
  reg reset;
  reg start_main;
  reg startstop_alarm_timer;
  reg toggle_AMPM_24;
  reg change_timezone;
  reg unix_sclk;
  reg unix_input;
  reg unix_load;

  wire [5:0][3:0] hhmmss;
  wire [7:0][3:0] ddmmyyyy;
  wire [2:0][7:0] weekascii;
  wire [3:0] timezone;
  wire AM_mode;
  wire PM_mode;
  wire timer_buzzer;
  wire alarm_buzzer;
  wire alarm_active_led;
  wire timer_active_led;
  wire [3:0] selected;
  wire [2:0] mode;
endmodule
