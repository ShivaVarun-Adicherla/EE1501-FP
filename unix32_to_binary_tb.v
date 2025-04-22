// We will load some unix values and see if we get the equivalent we are supposed to get after converting it in binary_time_converter
module unix32_to_binary_tb;
  reg  [31:0] unix32;
  wire [27:0] t;
  wire [ 4:0] hh;
  wire [ 5:0] mm;
  wire [ 5:0] ss;
  wire [ 4:0] DD;
  wire [ 3:0] MM;
  wire [10:0] YYYY;
  wire [ 2:0] week;
  unix32_to_binary DUT1 (
      unix32,
      t
  );
  binary_time_converter DUT2 (
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
    $dumpfile("simout.vcd");
    $dumpvars;
    $monitor("%2d:%2d:%2d\t%d\t%4d/%2d/%2d\t%d\t%d", hh, mm, ss, week, DD, MM, YYYY, t, unix32);
    unix32 = 1745309913;  //Tuesday, April 22, 2025 8:18:33 AM
    #1;
    unix32 = 1577840400;  //Wednesday, January 1, 2020 1:00:00 AM
    #1;
    unix32 = 1706326200;  //Saturday, January 27, 2024 3:30:00
    #1;
  end
endmodule
