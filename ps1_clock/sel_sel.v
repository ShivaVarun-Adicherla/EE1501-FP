
module sel_sel (
    input wire reset,
    input wire select,
    output reg [3:0] selected
);
  always @(posedge select or posedge reset) begin
    if (reset == 1) selected = 1;
    else begin
      case (selected)
        4'b0001: selected <= 4'b0010;
        4'b0010: selected <= 4'b0100;
        4'b0100: selected <= 4'b1000;
        4'b1000: selected <= 4'b0001;
        default: selected <= 4'b0001;
      endcase
    end
  end
endmodule
