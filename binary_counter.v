module binary_counter (
    input wire reset,
    input wire clk,
    input wire enable,
    input wire increment,
    input wire decrement,
    input wire [1:0] mode,
    input wire [1:0] selected,
    output reg [27:0] t
);
  always @(posedge clk or posedge reset) begin
    if (reset == 1) t = 0;
    else if (enable == 1) t = t + 1;
  end
  always @(posedge increment or posedge decrement) begin
    if (reset == 0) begin
      case (selected)
        //seconds
        2'b00:   t = increment ? t + 1 : t - 1;
        2'b01:   t = increment ? t + 60 : t - 60;
        2'b10:   t = increment ? t + 3600 : t - 3600;
        2'b11:   t = increment ? t + 86400 : t - 86400;
        default: t = t;
      endcase
    end
  end
endmodule
