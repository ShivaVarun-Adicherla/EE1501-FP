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
    output wire [5:0][3:0] hhmmss,  //Output
    output wire [7:0][3:0] ddmmyyyy,  //Output
    output wire [2:0][7:0] weekascii,
    output wire [3:0] timezone, //0001=GMT,0010=IST,0100=ET,1000=PT. Assume we have 4 leds on menu with inscriptions below them.
    //CONTROL OUTPUTS and ALARM/TIMER OUTPUTS
    output wire AM_mode,  //High if AM, zero in 24
    output wire PM_mode,  //High if PM,zero in 24
    output wire timer_buzzer,  //Buzzer for timer
    output wire alarm_buzzer,  //Buzzer for alarm
    output wire enable,  //Led to show if main clock is running
    output wire alarm_active_led,  //Led to show if alarm is running 
    output wire timer_active_led,  //Led to show if timer is running
    output wire [3:0] selected, //0001=Second, 0010=Minute, 0100=Hour, 1000=Day. To know what is selected. Suppose its 4 LEDS
    output wire [2:0] mode  //001=Main,010=Alarm,100=Timer. To know which mode we are in. Suppose its 3 LEDS
);
  wire AMPM_24;
  control_block control_block (
      reset,
      change_mode,
      select,
      change_timezone,
      start_main,
      toggle_AMPM_24,
      mode,
      selected,
      timezone,
      enable,
      AMPM_24
  );
  //For unix input and load(Refer to report for more info)
  wire [27:0] t_unix;
  unix32_to_binary unix32_inst (
      reset,
      unix_sclk,
      unix_input,
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
//Control Block

module control_block (
    input wire reset,
    input wire change_mode,
    input wire select,
    input wire change_timezone,
    input wire start_main,
    input wire toggle_AMPM_24,
    output wire [2:0] mode,
    output wire [3:0] selected,
    output wire [3:0] timezone,
    output reg enable,
    output reg AMPM_24
);

  // For toggling between modes with one button change_mode(001=NORMAL,010=ALARM,100=TIMER)
  sel_3 mode_sel (
      reset,
      change_mode,
      mode
  );
  //For toggling between modes with one button select(0001=Second, 0010=Minute, 0100=Hour, 1000=Day)
  sel_4 select_sel (
      reset,
      select,
      selected
  );

  sel_4 timezone_sel (
      reset,
      change_timezone,
      timezone
  );
  // If enable=1, count, else not. Th:is is for Main mode only.
  always @(posedge reset or posedge start_main) begin
    if (reset == 1) enable <= 0;
    else if (mode == 3'b001) enable <= ~enable;
  end
  // For Display mode 0=24 format, 1=AMPM
  always @(posedge reset or posedge toggle_AMPM_24) begin
    if (reset == 1) AMPM_24 <= 0;
    else AMPM_24 <= ~AMPM_24;
  end
endmodule
//Using One-Hot encoding to store the state. making a simple FSM that cycles
//from S1->S2->S3->S1...
//Default state is S1.
module sel_3 (
    input wire reset,
    input wire trigger,
    output reg [2:0] state
);
  reg [2:0] next_state;
  parameter S1 = 3'b001;
  parameter S2 = 3'b010;
  parameter S3 = 3'b100;
  always @(*) begin

    case (state)
      S1: next_state <= S2;
      S2: next_state <= S3;
      S3: next_state <= S1;
      default: next_state <= S1;
    endcase
  end
  always @(posedge trigger or posedge reset) begin
    if (reset) state <= S1;
    else state <= next_state;
  end
endmodule

//Using One-Hot encoding to store the state. making a simple FSM that cycles
//from S1->S2->S3->S4->S1...
//Default state is S1.
module sel_4 (
    input wire reset,
    input wire trigger,
    output reg [3:0] state
);
  reg [3:0] next_state;
  parameter S1 = 4'b0001;
  parameter S2 = 4'b0010;
  parameter S3 = 4'b0100;
  parameter S4 = 4'b1000;
  always @(*) begin
    case (state)
      S1: next_state <= S2;
      S2: next_state <= S3;
      S3: next_state <= S4;
      S4: next_state <= S1;
      default: next_state <= S1;
    endcase

  end

  always @(posedge trigger or posedge reset) begin
    if (reset) state <= S1;
    else state <= next_state;
  end
endmodule
//This reads the time from 32 bit unix timestamp which can be fed into a shift
//register using a external clock and input from a microcontroller.
module unix32_to_binary (
    input wire reset,
    input wire unix_sclk,
    input wire unix_data,
    output wire [27:0] t
);
  // NOTE: Unix Timestamp counts seconds from 1970 JAN 1 UTC. So for normalization, if we subtract total seconds till 2020 JAN 1 UTC, we will get the :wformat we want it in. If we load the number directly into memory using a timestamp, we will get UTC equivalent of it. After that we can apply offsets to have different timezones.
  reg [31:0] unix32;  //SIPO Shift Register
  assign t = unix32 - 18262 * 86400;
  always @(posedge unix_sclk or posedge reset) begin
    if (reset) unix32 <= 0;
    else unix32 <= {unix_data, unix32[31:1]};  //Assuming LSB comes first
  end
endmodule
//The main counter for the clock. Supports increment and decrement manually.
//Counts up on clock edge when enabled.
module binary_counter (
    input wire reset,
    input wire clk,
    input wire enable,
    input wire increment,
    input wire decrement,
    input wire [2:0] mode,
    input wire [3:0] selected,
    input wire [27:0] t_unix,
    input wire unix_load,

    output reg [27:0] t
);
  wire trigger;  //Using this for synthesiable design
  wire rst = (t >= 1947 * 86400) | reset;
  assign trigger = increment | decrement | unix_load | enable & clk;
  always @(posedge trigger or posedge rst) begin
    if (rst == 1) t <= 0;
    else begin
      if (enable & clk) t <= t + 1;
      else if ((increment || decrement) && mode[0]) begin
        case (selected)
          //seconds
          4'b0001: t <= increment ? t + 1 : t - 1;
          4'b0010: t <= increment ? t + 60 : t - 60;
          4'b0100: t <= increment ? t + 3600 : t - 3600;
          4'b1000: t <= increment ? t + 86400 : t - 86400;
          default: t <= t;
        endcase
      end else if (unix_load) t <= t_unix;
    end
  end
endmodule

/*
* If start is high it will count down and stop at 00 00 0000 00 00 00 (DD MM
* YYYY HH MM SS
* Can count convinently for 5 years of time but display is awkward due to
* mmonth and year limitations(although functionally it will work)
* startstop in another mode stops the timer
* startstop in this mode starts and stop,
* When it reaches zero buzzer rings. On pressing startstop it stops.
  */

module timer (
    input wire clk,
    input wire reset,
    input wire [27:0] t_main,
    input wire [2:0] mode,
    input wire change_mode,
    input wire startstop,
    input wire increment,
    input wire decrement,
    input wire [3:0] selected,
    output reg [27:0] t_timer,
    output wire timer_buzzer,
    output reg timer_active
);

  //timer activation logic.
  always @(posedge startstop or posedge reset) begin
    if (reset == 1) begin
      timer_active <= 0;
    end else
      timer_active <= (mode[2])&~timer_active; //when in timer MODE, triggering will TOGGLE. When outside it will just stop.
  end

  wire trigger;
  assign trigger = increment | decrement | change_mode | clk & timer_active;
  // Setting to initial value on entering mode
  always @(posedge trigger or posedge reset) begin
    if (reset == 1) t_timer = 0;
    else if (timer_active && clk && t_timer != 0) t_timer = t_timer - 1;
    else if (!timer_active && (increment | decrement) && mode[2]) begin
      case (selected)
        //seconds
        4'b0001: t_timer = increment ? t_timer + 1 : t_timer - 1;
        4'b0010: t_timer = increment ? t_timer + 60 : t_timer - 60;
        4'b0100: t_timer = increment ? t_timer + 3600 : t_timer - 3600;
        4'b1000: t_timer = increment ? t_timer + 86400 : t_timer - 86400;
        default: t_timer = t_timer;
      endcase
    end
  end


  assign timer_buzzer = (t_timer == 0) & timer_active;
endmodule

/*
* If start is high it will compare if the value in t_main>=t_alarm. If
* satisfied timer_buzzer will be set to high.
*
* This module on getting into this mode when off will set the t_alarm=t_main.
*
* After this it can be incremented and decremented to any date and time. 
* After this we toggle startstop once. Then it starts the comparison.
*
* When pressed again it turns off.
  */

module alarm (
    input wire reset,
    input wire [27:0] t_main,
    input wire [2:0] mode,
    input wire change_mode,
    input wire startstop,
    input wire increment,
    input wire decrement,
    input wire [3:0] selected,
    output reg [27:0] t_alarm,
    output wire timer_buzzer,
    output reg alarm_active
);
  wire trigger;  //For synthesizable design
  assign trigger = increment | decrement | startstop | change_mode;
  //alarm activation logic.
  always @(posedge trigger or posedge reset) begin
    if (reset == 1) begin
      alarm_active = 0;
      t_alarm = 0;
    end else if (mode[1]) begin
      if (startstop == 1)
        alarm_active <= (mode[1])&~alarm_active; //when in ALARM MODE, triggering will TOGGLE. When outside it will just stop.
      else if (increment || decrement) begin
        case (selected)
          //seconds
          4'b0001: t_alarm = increment ? t_alarm + 1 : t_alarm - 1;
          4'b0010: t_alarm = increment ? t_alarm + 60 : t_alarm - 60;
          4'b0100: t_alarm = increment ? t_alarm + 3600 : t_alarm - 3600;
          4'b1000: t_alarm = increment ? t_alarm + 86400 : t_alarm - 86400;
          default: t_alarm = t_alarm;
        endcase
      end
    end else begin
      if (startstop == 1)
        alarm_active <= (mode[1])&~alarm_active; //when in ALARM MODE, triggering will TOGGLE. When outside it will just stop.
      if (!alarm_active && change_mode) t_alarm = t_main;
    end


  end
  // Setting to initial value on entering mode
  assign timer_buzzer = (t_main >= t_alarm) & alarm_active;
endmodule

module binary_time_converter (
    input  wire [27:0] t,
    output wire [ 4:0] hh,
    output wire [ 5:0] mm,
    output wire [ 5:0] ss,
    output reg  [ 4:0] DD,
    output reg  [ 3:0] MM,
    output reg  [10:0] YYYY,
    output wire [ 2:0] week
);
  parameter DAY = 86400;
  parameter HOUR = 3600;
  parameter MINUTE = 60;
  wire [11:0] days;
  wire [16:0] timeinday, timeinhour;
  reg [11:0] remainingdays;
  assign days = t / DAY;

  assign timeinday = t % DAY;
  assign hh = timeinday / HOUR;

  assign timeinhour = timeinday % HOUR;
  assign mm = timeinhour / MINUTE;

  assign ss = timeinhour % MINUTE;
  // Week to be assigned as SUN=0,MON=1,TUE=2,WED=3,THU=4,FRI=5,SAT=6
  assign week = (3 + days) % 7;
  always @(*) begin
    //Computing YYYY
    YYYY = 0000;
    //days + 1 because initially days = 0 for first day of the year when it should be one 
    if (days + 1 <= 366) begin
      YYYY = 2020;
      remainingdays = days;
    end else if (days + 1 <= 366 + 365) begin
      YYYY = 2021;
      remainingdays = days - 366;
    end else if (days + 1 <= 366 + 2 * 365) begin
      YYYY = 2022;
      remainingdays = days - 366 - 365;
    end else if (days + 1 <= 366 + 3 * 365) begin
      YYYY = 2023;
      remainingdays = days - 366 - 2 * 365;
    end else if (days + 1 <= 2 * 366 + 3 * 365) begin
      YYYY = 2024;
      remainingdays = days - 366 - 3 * 365;
    end else if (days + 1 <= 2 * 366 + 4 * 365) begin
      YYYY = 2025;
      remainingdays = days - 2 * 366 - 3 * 365;
    end
    //Computing Month
    if (YYYY == 2020 || YYYY == 2024) begin  // leap years
      if (remainingdays < 31) begin
        MM = 1;
        DD = remainingdays + 1;
      end else if (remainingdays < 60) begin
        MM = 2;
        DD = remainingdays - 31 + 1;
      end else if (remainingdays < 91) begin
        MM = 3;
        DD = remainingdays - 60 + 1;
      end else if (remainingdays < 121) begin
        MM = 4;
        DD = remainingdays - 91 + 1;
      end else if (remainingdays < 152) begin
        MM = 5;
        DD = remainingdays - 121 + 1;
      end else if (remainingdays < 182) begin
        MM = 6;
        DD = remainingdays - 152 + 1;
      end else if (remainingdays < 213) begin
        MM = 7;
        DD = remainingdays - 182 + 1;
      end else if (remainingdays < 244) begin
        MM = 8;
        DD = remainingdays - 213 + 1;
      end else if (remainingdays < 274) begin
        MM = 9;
        DD = remainingdays - 244 + 1;
      end else if (remainingdays < 305) begin
        MM = 10;
        DD = remainingdays - 274 + 1;
      end else if (remainingdays < 335) begin
        MM = 11;
        DD = remainingdays - 305 + 1;
      end else begin
        MM = 12;
        DD = remainingdays - 335 + 1;
      end
    end else begin  // non-leap years
      if (remainingdays < 31) begin
        MM = 1;
        DD = remainingdays + 1;
      end else if (remainingdays < 59) begin
        MM = 2;
        DD = remainingdays - 31 + 1;
      end else if (remainingdays < 90) begin
        MM = 3;
        DD = remainingdays - 59 + 1;
      end else if (remainingdays < 120) begin
        MM = 4;
        DD = remainingdays - 90 + 1;
      end else if (remainingdays < 151) begin
        MM = 5;
        DD = remainingdays - 120 + 1;
      end else if (remainingdays < 181) begin
        MM = 6;
        DD = remainingdays - 151 + 1;
      end else if (remainingdays < 212) begin
        MM = 7;
        DD = remainingdays - 181 + 1;
      end else if (remainingdays < 243) begin
        MM = 8;
        DD = remainingdays - 212 + 1;
      end else if (remainingdays < 273) begin
        MM = 9;
        DD = remainingdays - 243 + 1;
      end else if (remainingdays < 304) begin
        MM = 10;
        DD = remainingdays - 273 + 1;
      end else if (remainingdays < 334) begin
        MM = 11;
        DD = remainingdays - 304 + 1;
      end else begin
        MM = 12;
        DD = remainingdays - 334 + 1;
      end
    end
  end

endmodule

// This module chooses which time value to send to display. Also offsets the
// time based on timezone.
module tmux (
    input wire [27:0] t_main,
    input wire [27:0] t_alarm,
    input wire [27:0] t_timer,
    input wire [2:0] mode,  //001=Main,010=Alarm,100=Timer
    input wire [3:0] timezone,  //0001=GMT,0010=IST,0100=ET,1000=PT.
    output reg [27:0] t_out
);
  always @(*) begin

    case (mode)
      3'b001:  t_out = t_main;
      3'b010:  t_out = t_alarm;
      3'b100:  t_out = t_timer;
      default: t_out = 28'd0;
    endcase
    if (mode[1] | mode[0]) begin
      case (timezone)
        4'b0010: t_out = t_out + 19800;
        4'b0100: t_out = t_out - 18000;
        4'b1000: t_out = t_out - 28800;
        default: t_out = t_out;
      endcase
    end
  end
endmodule

//Handles conversion into BCD formats and AMPM Mode. 
//Fixes date when viewing in timer mode.
module time_to_output (
    input wire [4:0] hh,
    input wire [5:0] mm,
    input wire [5:0] ss,
    input wire [4:0] DD,
    input wire [3:0] MM,
    input wire [10:0] YYYY,
    input wire [2:0] week,
    input wire [2:0] mode,
    input wire AMPM_24,
    output reg [5:0][3:0] hhmmss,
    output reg [7:0][3:0] ddmmyyyy,
    output reg [2:0][7:0] weekascii,
    output reg AM_mode,
    output reg PM_mode
);
  reg [4:0] hhtemp;

  always @(*) begin
    hhmmss[0] = ss % 10;
    hhmmss[1] = ss / 10;
    hhmmss[2] = mm % 10;
    hhmmss[3] = mm / 10;
    if (AMPM_24 == 0 || mode[2]) begin
      AM_mode = 0;
      PM_mode = 0;
      hhtemp  = hh;
    end else begin
      if (hh == 0) begin
        AM_mode = 1;
        hhtemp  = 12;
      end else if (hh < 12) begin
        AM_mode = 1;
        hhtemp  = hh;
      end else if (hh == 12) begin
        AM_mode = 0;
        hhtemp  = hh;
      end else begin
        AM_mode = 0;
        hhtemp  = hh - 12;
      end
      PM_mode = ~AM_mode;

    end
    hhmmss[4] = hhtemp % 10;
    hhmmss[5] = hhtemp / 10;
    case (YYYY)
      11'd2020: ddmmyyyy[3:0] = (mode[2]) ? 16'h0000 : 16'h2020;
      11'd2021: ddmmyyyy[3:0] = (mode[2]) ? 16'h0001 : 16'h2021;
      11'd2022: ddmmyyyy[3:0] = (mode[2]) ? 16'h0002 : 16'h2022;
      11'd2023: ddmmyyyy[3:0] = (mode[2]) ? 16'h0003 : 16'h2023;
      11'd2024: ddmmyyyy[3:0] = (mode[2]) ? 16'h0004 : 16'h2024;
      11'd2025: ddmmyyyy[3:0] = (mode[2]) ? 16'h0005 : 16'h2025;
    endcase
    ddmmyyyy[4] = MM % 10;
    ddmmyyyy[5] = MM / 10;
    ddmmyyyy[6] = DD % 10;
    ddmmyyyy[7] = DD / 10;
    if (mode[2] == 0) begin
      case (week)
        3'd0: weekascii = "SUN";
        3'd1: weekascii = "MON";
        3'd2: weekascii = "TUE";
        3'd3: weekascii = "WED";
        3'd4: weekascii = "THU";
        3'd5: weekascii = "FRI";
        3'd6: weekascii = "SAT";
        default: weekascii = "ERR";
      endcase
    end else weekascii = "  ";
  end
endmodule
