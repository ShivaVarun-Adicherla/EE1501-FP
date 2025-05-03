`timescale 1s / 1ms
//Defining Macro
`define en(target) begin target=1; #0.2; target=0; #0.2; end
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
  reg [128:0][7:0] comment;
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
  wire enable;
  wire [3:0] selected;
  wire [2:0] mode;
  integer i;
  reg [31:0] tempunix;
  top_module dut (
      .clk(clk),
      .change_mode(change_mode),
      .increment(increment),
      .decrement(decrement),
      .select(select),
      .reset(reset),
      .start_main(start_main),
      .startstop_alarm_timer(startstop_alarm_timer),
      .toggle_AMPM_24(toggle_AMPM_24),
      .change_timezone(change_timezone),
      .unix_sclk(unix_sclk),
      .unix_input(unix_input),
      .unix_load(unix_load),
      .hhmmss(hhmmss),
      .ddmmyyyy(ddmmyyyy),
      .weekascii(weekascii),
      .timezone(timezone),
      .AM_mode(AM_mode),
      .PM_mode(PM_mode),
      .timer_buzzer(timer_buzzer),
      .alarm_buzzer(alarm_buzzer),
      .alarm_active_led(alarm_active_led),
      .timer_active_led(timer_active_led),
      .enable(enable),
      .selected(selected),
      .mode(mode)
  );
  initial begin

    clk = 0;
    change_mode = 0;
    increment = 0;
    decrement = 0;
    select = 0;
    reset = 0;
    start_main = 0;
    startstop_alarm_timer = 0;
    toggle_AMPM_24 = 0;
    change_timezone = 0;
    unix_sclk = 0;
    unix_input = 0;
    unix_load = 0;

    $monitor(
        "hh:mm:ss=%0d%0d:%0d%0d:%0d%0d | Date=%0d%0d-%0d%0d-%0d%0d%0d%0d | TZ=%b | Mode=%b | Sel=%b | Run=%b | Alarm=%b | Timer=%b | AM=%b | PM=%b | BuzzT=%b | BuzzA=%b",
        hhmmss[5], hhmmss[4], hhmmss[3], hhmmss[2], hhmmss[1], hhmmss[0], ddmmyyyy[7], ddmmyyyy[6],
        ddmmyyyy[5], ddmmyyyy[4], ddmmyyyy[3], ddmmyyyy[2], ddmmyyyy[1], ddmmyyyy[0], timezone,
        mode, selected, enable, alarm_active_led, timer_active_led, AM_mode, PM_mode, timer_buzzer,
        alarm_buzzer);
    $dumpfile("simout.vcd");
    $dumpvars;
    comment = "Resetting and starting clock";
    #1;
    `en(reset);
    `en(start_main);
    #100;
    comment = "Stopping clock and incrementing decrementing";
    `en(start_main);
    repeat (5) `en(decrement);
    `en(select);
    repeat (5) `en(increment);
    `en(select);
    repeat (10) `en(increment);
    `en(select);
    repeat (5) `en(increment);
    #20;
    comment = "starting and changing to AM/PM Mode";
    `en(start_main);
    `en(toggle_AMPM_24);
    #10;
    comment = "Demonstrating Alarm";
    `en(change_mode);
    `en(select);
    `en(select);
    `en(increment);
    `en(startstop_alarm_timer);
    repeat (5) `en(change_mode);
    #65;
    `en(startstop_alarm_timer);
    #5;
    comment = "Demonstrating timer for 10 mins";
    repeat (2) `en(change_mode);
    repeat (10) `en(increment);
    `en(startstop_alarm_timer);
    #610;
    `en(startstop_alarm_timer);
    #5;
    `en(change_mode);
    #5;
    comment = "Demonstrating Timezones";
    repeat (4) begin
      `en(change_timezone);
      #10;
    end
    comment = "Demonstrating loading directly from serial input using UNIX Timestamp";
    `en(start_main);
    //Suppose we want to load Tuesday, April 22, 2025 8:18:33 AM For this we
    //need a external input from another deevice like a microcontroller. To
    //simmulate the input we will just run a for loop to input each bit in
    //unix_data and give a clock to unix_sclk then unix_load.
    tempunix = 1745309913;
    for (i = 0; i < 32; i++) begin
      unix_input = tempunix[i];
      #0.001;
      #0.001;
      unix_sclk = 1;
      #0.001;
      unix_sclk = 0;
    end
    unix_input = 0;
    `en(unix_load);
    `en(start_main);
    #20;
    $finish;


  end
endmodule
