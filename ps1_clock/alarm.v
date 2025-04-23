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
    input wire [1:0] mode,
    input wire startstop,
    input wire increment,
    input wire decrement,
    input wire selected,
    output reg [27:0] t_alarm,
    output wire timer_buzzer
);
  reg alarm_active;

  //alarm activation logic.
  always @(posedge startstop or posedge reset) begin
    if (reset == 1) begin
      alarm_active = 0;
      t_alarm = 0;
    end else
      alarm_active <= (mode == 1)&~alarm_active; //when in ALARM MODE, triggering will TOGGLE. When outside it will just stop.
  end
  // Setting to initial value on entering mode
  always @(posedge (mode == 1)) begin
    if (!alarm_active) t_alarm = t_main;
  end


  always @(posedge increment or posedge decrement) begin
    if (reset == 0) begin
      case (selected)
        //seconds
        2'b00:   t_alarm = increment ? t_alarm + 1 : t_alarm - 1;
        2'b01:   t_alarm = increment ? t_alarm + 60 : t_alarm - 60;
        2'b10:   t_alarm = increment ? t_alarm + 3600 : t_alarm - 3600;
        2'b11:   t_alarm = increment ? t_alarm + 86400 : t_alarm - 86400;
        default: t_alarm = t_alarm;
      endcase
    end
  end

  assign timer_buzzer = (t_main >= t_alarm) & alarm_active;
endmodule
