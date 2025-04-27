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
