
module sel_sel (
    input wire reset,
    input wire select,
    output reg [1:0] selected
);
  always @(posedge select or posedge reset) begin
    if (reset == 1) selected = 0;
    else selected = (selected + 1);
  end
endmodule
