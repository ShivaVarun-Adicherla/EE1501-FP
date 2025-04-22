module mode_sel (
    input wire reset,
    input wire change_mode,
    output reg [1:0] mode
);
  always @(posedge change_mode or posedge reset) begin
    if (reset == 1) mode = 0;
    else mode = (mode + 1) % 3;
  end
endmodule
