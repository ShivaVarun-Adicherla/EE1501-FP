module tmux (
    input  wire [27:0] t_main,
    input  wire [27:0] t_alarm,
    input  wire [27:0] t_timer,
    input  wire [ 1:0] mode,
    output reg  [27:0] t_out
);
  always @(*) begin
    case (mode)
      2'd0: t_out = t_main;
      2'd1: t_out = t_alarm;
      2'd2: t_out = t_timer;
      default: t_out = 28'd0;
    endcase
  end
endmodule
;
