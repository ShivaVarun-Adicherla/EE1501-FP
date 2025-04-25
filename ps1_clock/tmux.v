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

