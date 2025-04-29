`timescale 1s / 1ms
module sel_3_tb;
  reg reset;
  reg trigger;
  wire [2:0] state;
  sel_3 dut (
      reset,
      trigger,
      state
  );
  initial begin
    reset   = 0;
    trigger = 0;
    $dumpfile("simout.vcd");
    $dumpvars(0, sel_3_tb);
    #1;
    reset = 1;
    #1;
    reset = 0;
    repeat (5) begin

      #1 trigger = 1;
      #1 trigger = 0;
    end
  end
endmodule

