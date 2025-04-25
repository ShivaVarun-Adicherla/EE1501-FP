module mode_sel (
    input wire reset,
    input wire change_mode,
    output reg [2:0] mode
);
  always @(posedge change_mode or posedge reset) begin
    if (reset == 1) mode = 1;
    else begin
      case (mode)
        3'b001:  mode <= 3'b010;
        3'b010:  mode <= 3'b100;
        3'b100:  mode <= 3'b001;
        default: mode <= 3'b001;
      endcase
    end
  end
endmodule
