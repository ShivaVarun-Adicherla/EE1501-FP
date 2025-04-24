module top_module (
    //These inputs are from not controlled by mennu
    input wire clk,
    //These inputs will be controlled by menu
    input wire change_mode,
    input wire increment,  //Increases the selected parameter by 1.(second,minute,hour,day)
    input wire decrement,  //Decreases the selected parameter by 1.(second,minute,hour,day)
    input wire select,  //To select which parameter we are changing.(Advised to use when clock is stopped, or for timer/alarm)
    input wire reset,  //Resets everything to default values(MUST BE USED ON STARTUP)
    input wire start_main,  //Toggles if clock is running or not. 
    input wire startstop_alarm_timer,
    output [5:0][3:0] hhmmss,  //Output
    output [7:0][3:0] ddmmyyyy,  //Output
    output [2:0][7:0] weekascii,
    output AM_mode,  //High if AM, zero in 24
    output PM_mode,  //High if PM,zero in 24
    output timer_buzzer,  //Buzzer for timer
    output alarm_buzzer  //Buzzer for alarm
);

  // For toggling between modes with one button(0=NORMAL,1=ALARM,2=TIMER)
  wire [1:0] mode;
  mode_sel mode_sel (
      reset,
      change_mode,
      mode
  );

  wire [1:0] selected;
  sel_sel select_sel (
      reset,
      select,
      selected
  );
  // If enable=1, count, else not. This is for Main mode only.
  reg enable;
  always @(posedge reset or posedge start_main) begin
    if (reset == 1) enable = 0;
    else if (mode == 2'b0) enable = ~enable;
  end

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
      alarm_buzzer

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
      timer_buzzer

  );



  //Choosing what to display based on mode
  wire [27:0] t_out;
  tmux tmux_inst (
      t_main,
      t_alarm,
      t_timer,
      mode,
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
      hhmmss,
      ddmmyyyy,
      weekascii
  );
endmodule
