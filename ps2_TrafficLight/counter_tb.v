module counter_tb();
  reg enable, reset, clk;
  wire out;

  counter #(.TIME(12)) inst0 (.enable(enable), .clk(clk), .reset(reset), .overflow(out));
  always #1 clk = ~clk;
  initial begin
    $dumpfile("counter_tb.vcd");
    $dumpvars(0);
    reset = 1;
    enable = 0;
    clk = 0;
    #3 reset = 0;
    enable = 1;
    #30 reset = 1;
    #10 reset = 0;
    #10 reset = 1;
    #1 reset = 0;
    #10;
    $finish;
  end
endmodule
