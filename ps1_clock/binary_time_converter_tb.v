`timescale 1s / 1ms
module binary_time_converter_tb;
  reg [27:0] t;
  wire [4:0] hh;
  wire [5:0] mm;
  wire [5:0] ss;
  wire [4:0] DD;
  wire [3:0] MM;
  wire [10:0] YYYY;
  wire [2:0] week;
  integer i;
  binary_time_converter DUT (
      t,
      hh,
      mm,
      ss,
      DD,
      MM,
      YYYY,
      week

  );
  initial begin
    $monitor("%2d:%2d:%2d\t%d\t%4d/%2d/%2d\t%d", hh, mm, ss, week, DD, MM, YYYY, t);
    $dumpfile("simout.vcd");
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


