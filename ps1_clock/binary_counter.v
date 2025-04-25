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
  assign trigger = increment | decrement | unix_load | enable & clk;
  always @(posedge trigger or posedge reset) begin
    if (reset == 1) t = 0;
    else if (enable & clk) t = t + 1;
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
endmodule
