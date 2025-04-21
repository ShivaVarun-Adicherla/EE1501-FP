`timescale 1s / 1ms
module binary_time_converter_tb;
  reg [27:0] t;
  wire [7:0] hh;
  wire [7:0] mm;
  wire [7:0] ss;
  wire [7:0] DD;
  wire [7:0] MM;
  wire [11:0] YYYY;
  integer i;
  binary_time_converter DUT (
      t,
      hh,
      mm,
      ss,
      DD,
      MM,
      YYYY
  );
  initial begin
    $monitor("%2d:%2d:%2d\t%4d/%2d/%2d\t%d", hh, mm, ss, DD, MM, YYYY, t);
    $dumpfile("binary_time_converter.vcd");
    $dumpvars(0, binary_time_converter_tb);
    t = 1;
    #1
    for (i = 0; i < 2000; i = i + 1) begin
      t = t + 86400;
      #1;
    end
    $finish;
  end
endmodule


