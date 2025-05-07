module trafficSignalDisplay #(
    parameter TYPE = 2,
    DELAY = 10
) (
    output reg [2:0] Signal,
    output reg Walk,
    Buzzer,
    output wire disableClock,
    input wire [2:0] currentState,
    input wire [1:0] emergencySignals,
    input reset,
    clk
);

  parameter S0 = 3'd0, S1 = 3'd1, S2 = 3'd2, S3 = 3'd3, S4 = 3'd4;
  parameter RED = 3'd1, YELLOW = 3'd2, GREEN = 3'd4; //These are basically a single bus, to set state of single light
  parameter HIGH = 1'b1, LOW = 1'b0;
  parameter EMERGENCY_LEFT = 2'd2, EMERGENCY_RIGHT = 2'd1;
  reg State;
  wire enableTimer, lNextEvent;

  counter #(
      .TIME(DELAY)
  ) Z0 (
      .clk(clk),
      .reset(reset),
      .enable(enableTimer),
      .overflow(lNextEvent)
  );

  generate
    assign enableTimer  = State & ~emergencySignals[0];
    assign disableClock = State;

    if (TYPE == 2) begin
      always @(*) begin
        if(emergencySignals[0])
          State = HIGH;
      end
      always @(posedge reset or posedge lNextEvent) begin
        if (reset) State <= LOW;  //If State is LOW, It's in passthrough mode.
        else if (~emergencySignals && lNextEvent)
          State <= LOW;  //Return from Emergency to Normal Mode
      end
    end else if (TYPE == 1) begin
      always @(*) begin
        if(|emergencySignals)
          State = HIGH;
      end
      always @(posedge reset or posedge lNextEvent) begin
        if (reset) State <= LOW;  //If State is LOW, It's in passthrough mode.
        else if (~(|emergencySignals) && lNextEvent)
          State <= LOW;  //Return from Emergency to Normal Mode
      end
    end
  endgenerate

  always @(*) begin
    if (State) begin
      Signal = RED;
      Walk   = LOW;
      Buzzer = HIGH;
    end else
      case (currentState)
        S0: begin
          Signal = GREEN;
          Buzzer = LOW;
          Walk   = LOW;
        end
        S1: begin
          Signal = YELLOW;
          Buzzer = LOW;
          Walk   = LOW;
        end
        S2: begin
          Signal = RED;
          Buzzer = LOW;
          Walk   = HIGH;
        end
        S3: begin
          Signal = RED;
          Buzzer = HIGH;
          Walk   = HIGH;
        end
        S4: begin
          Signal = YELLOW;
          Buzzer = LOW;
          Walk   = LOW;
        end
        default: begin
          Signal = GREEN;
          Buzzer = LOW;
          Walk   = LOW;
        end
      endcase
  end
endmodule
