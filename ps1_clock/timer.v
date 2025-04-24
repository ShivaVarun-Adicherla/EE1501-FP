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
    input wire [1:0] mode,
    input wire startstop,
    input wire increment,
    input wire decrement,
    input wire [1:0] selected,
    output reg [27:0] t_timer,
    output wire timer_buzzer
);
  reg timer_active;

  //timer activation logic.
  always @(posedge startstop or posedge reset) begin
    if (reset == 1) begin
      timer_active = 0;
      t_timer = 0;
    end else
      timer_active <= (mode == 1)&~timer_active; //when in timer MODE, triggering will TOGGLE. When outside it will just stop.
  end
  // Setting to initial value on entering mode
  always @(posedge (mode == 1)) begin
    if (!timer_active) t_timer = 0;
  end

  //Timer logic
  always @(posedge clk) begin
    if (timer_active && t_timer != 0) t_timer = t_timer - 1;
  end
  //Setting time logic
  always @(posedge increment or posedge decrement) begin
    if (reset == 0) begin
      case (selected)
        //seconds
        2'b00:   t_timer = increment ? t_timer + 1 : t_timer - 1;
        2'b01:   t_timer = increment ? t_timer + 60 : t_timer - 60;
        2'b10:   t_timer = increment ? t_timer + 3600 : t_timer - 3600;
        2'b11:   t_timer = increment ? t_timer + 86400 : t_timer - 86400;
        default: t_timer = t_timer;
      endcase
    end
  end

  assign timer_buzzer = (t_timer == 0) & timer_active;
endmodule
