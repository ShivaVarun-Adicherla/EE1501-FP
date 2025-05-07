module trafficSignalDisplay_tb ();

  parameter S0 = 3'd0, S1 = 3'd1, S2 = 3'd2, S3 = 3'd3, S4 = 3'd4;
  parameter EMERGENCY_LEFT = 2'd2, EMERGENCY_RIGHT = 2'd1, EMERGENCY_NONE = 2'b00;

  wire [2:0] out;
  wire Walk, Buzzer, enableClock;
  reg rst, clk;
  reg [2:0] State;
  reg [1:0] eSig;

  trafficSignalDisplay inst1 (
      .Signal(out),
      .Walk(Walk),
      .Buzzer(Buzzer),
      .enableClock(enableClock),
      .currentState(State),
      .emergencySignals(eSig),
      .reset(rst),
      .clk(clk)
  );

  always #1 clk = ~clk;

  initial begin
    $dumpfile("trafficSignalDisplay_tb.vcd");
    $dumpvars(0);

    rst   = 1;
    State = S0;
    eSig  = EMERGENCY_NONE;
    clk   = 0;
    #1 rst = 0;

    #5 State = S1;
    #5 State = S2;
    #5 State = S3;
    #5 State = S4;

    #10 eSig = EMERGENCY_RIGHT;
    #9 eSig = EMERGENCY_NONE;
    #30;
    $finish;
  end
endmodule
