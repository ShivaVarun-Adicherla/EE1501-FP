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
      timer_active = 0;
    end else
      timer_active <= (mode[2])&~timer_active; //when in timer MODE, triggering will TOGGLE. When outside it will just stop.
  end

  wire trigger;
  assign trigger = increment | decrement | change_mode | clk & timer_active;
  // Setting to initial value on entering mode
  always @(posedge trigger or posedge reset) begin
    if (reset == 1) t_timer = 0;
    else if (timer_active && clk == 1 && t_timer != 0) t_timer = t_timer - 1;
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
