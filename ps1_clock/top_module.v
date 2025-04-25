module top_module (
    //These inputs are from not controlled by mennu
    input wire clk,
    //These inputs will be controlled by menu
    //BUTTON INPUTS
    input wire change_mode,
    input wire increment,  //Increases the selected parameter by 1.(second,minute,hour,day)
    input wire decrement,  //Decreases the selected parameter by 1.(second,minute,hour,day)
    input wire select,  //To select which parameter we are changing.(Advised to use when clock is stopped, or for timer/alarm)
    input wire reset,  //Resets everything to default values(MUST BE USED ON STARTUP)
    input wire start_main,  //Toggles if clock is running or not. 
    input wire startstop_alarm_timer, //To start and stop the alarm and timer modes and their buzzers.
    input wire toggle_AMPM_24,  //To toggle between AMPM and 24 HOUR format.
    input wire change_timezone,  //Rotates between 4 timezones

    //EXPOSED PINS as input from a microcontroller or similar device to load
    //UNIX time stamp into the clock using a SIPO Shift register.
    input wire unix_sclk,
    input wire unix_input,
    input wire unix_load,
    //DISPLAY OUTPUT
    output [5:0][3:0] hhmmss,  //Output
    output [7:0][3:0] ddmmyyyy,  //Output
    output [2:0][7:0] weekascii,
    output [3:0] timezone, //0001=GMT,0010=IST,0100=ET,1000=PT. Assume we have 4 leds on menu with inscriptions below them.
    //CONTROL OUTPUTS and ALARM/TIMER OUTPUTS
    output AM_mode,  //High if AM, zero in 24
    output PM_mode,  //High if PM,zero in 24
    output timer_buzzer,  //Buzzer for timer
    output alarm_buzzer,  //Buzzer for alarm
    output alarm_active_led,  //Led to show if alarm is running 
    output timer_active_led,  //Led to show if timer is running
    output [3:0] selected, //0001=Second, 0010=Minute, 0100=Hour, 1000=Day. To know what is selected. Suppose its 4 LEDS
    output [2:0] mode  //001=Main,010=Alarm,100=Timer. To know which mode we are in. Suppose its 3 LEDS
);

  // For toggling between modes with one button change_mode(001=NORMAL,010=ALARM,100=TIMER)
  mode_sel mode_sel (
      reset,
      change_mode,
      mode
  );
  //For toggling between modes with one button select(0001=Second, 0010=Minute, 0100=Hour, 1000=Day)
  sel_sel select_sel (
      reset,
      select,
      selected
  );

  sel_sel timezone_sel (
      reset,
      change_timezone,
      timezone
  );
  // If enable=1, count, else not. This is for Main mode only.
  reg enable;
  always @(posedge reset or posedge start_main) begin
    if (reset == 1) enable = 0;
    else if (mode == 2'b0) enable = ~enable;
  end
  // For Display mode 0=24 format, 1=AMPM
  reg AMPM_24;
  always @(posedge reset or posedge toggle_AMPM_24) begin
    if (reset == 1) AMPM_24 = 0;
    else if (mode == 2'b0) AMPM_24 = ~AMPM_24;
  end
  //For unix input and load(Refer to report for more info)
  wire [27:0] t_unix;
  unix32_to_binary unix32_inst (
      reset,
      unix_sclk,
      unix_data,
      t_unix
  );
  //counter for actual time.
  wire [27:0] t_main;
  binary_counter main_counter (
      reset,
      clk,
      enable,
      increment,
      decrement,
      mode,
      selected,
      t_unix,
      unix_load,
      t_main
  );

  //ALARM
  wire [27:0] t_alarm;
  alarm alarm_inst (
      reset,
      t_main,
      mode,
      change_mode,
      startstop_alarm_timer,
      increment,
      decrement,
      selected,

      t_alarm,
      alarm_buzzer,
      alarm_active_led

  );
  //TIMER
  wire [27:0] t_timer;
  timer timer_inst (
      clk,
      reset,
      t_main,
      mode,
      change_mode,
      startstop_alarm_timer,
      increment,
      decrement,
      selected,

      t_timer,
      timer_buzzer,
      timer_active_led

  );



  //Choosing what to display based on mode and also implements timezone
  wire [27:0] t_out;
  tmux tmux_inst (
      t_main,
      t_alarm,
      t_timer,
      mode,
      timezone,
      t_out
  );
  wire [ 4:0] hh;
  wire [ 5:0] mm;
  wire [ 5:0] ss;
  wire [ 4:0] DD;
  wire [ 3:0] MM;
  wire [10:0] YYYY;
  wire [ 2:0] week;
  binary_time_converter maincountout (
      t_out,
      hh,
      mm,
      ss,
      DD,
      MM,
      YYYY,
      week

  );

  time_to_output maindisplay (
      hh,
      mm,
      ss,
      DD,
      MM,
      YYYY,
      week,
      mode,
      AMPM_24,
      hhmmss,
      ddmmyyyy,
      weekascii,
      AM_mode,
      PM_mode
  );
endmodule
