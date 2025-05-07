module counter #(
    parameter TIME = 30
) (
    output overflow,
    input  enable,
    clk,
    reset
);

  /*
* This module is like an overflow timer found in many MCUs.
* The basic idea is that the system does something or is
* interupted from it's routine to perform a task, when the
* overflow signal gets a posedge.
*
* WARNING: The reset in this counter is only supposed to
* bring the counter back to a known state. Using it for
* other logic is discouraged, since there's posibility of
* a false edge, if the timing of reset is in such a way
* that the overflow signal was LOW, then the overflow is
* pushed HIGH, since the counter got reset to TIME.
*
* Also be carefull when passing the TIME parameter, due to
* it's  implementation, we will have issues when deaing with
* TIME values less than 3(exclusive).
*/

  reg [$clog2(TIME) - 1:0] count;

  always @(posedge clk, posedge reset) begin
    if (reset) count <= TIME;  //We have TIME here because this state is init state.
    else if (enable) count <= (count - 1 > TIME) ? TIME : count - 1;
  end

  //We will have a posedge when the count rolls over to TIME
  assign overflow = count[$clog2(TIME)-1];
endmodule

module trafficFSM (
    output reg [2:0] currentState,
    output reg [3:0] enableCounters,
    input triggerNextEvent,
    reset,
    pedButton
);

  reg [2:0] nextState;
  parameter S0 = 3'd0, S1 = 3'd1, S2 = 3'd2, S3 = 3'd3, S4 = 3'd4;
  parameter T3 = 4'b1000, T0 = 4'b0001, T1 = 4'b0010, T2 = 4'b0100;

  reg pedestrianPresent, pedestrianReset;
  always @(posedge pedButton, posedge pedestrianReset) begin
    if (pedestrianReset) pedestrianPresent <= 1'b0;
    else if (pedButton) pedestrianPresent <= 1'b1;
  end

  //The sequential part of the FSM (CurrentState gets changed here at edges)
  always @(posedge triggerNextEvent or posedge reset) begin
    if (reset) begin
      currentState <= S0;
      pedestrianPresent <= 1'b0;
      pedestrianReset <= 1'b0;
    end else begin
      currentState <= nextState;
    end
  end

  //The Combinational part of FSM (nextState gets predicted here)
  always @(*) begin
    casez (currentState)
      S0: begin
        if (pedestrianPresent) nextState = S1;
        else nextState = S0;

        enableCounters  = T3;
        pedestrianReset = 1'b0;
      end
      S1: begin
        nextState = S2;
        enableCounters = T0;
        pedestrianReset = 1'b0;
      end
      S2: begin
        nextState = S3;
        enableCounters = T1;
        pedestrianReset = 1'b0;
      end
      S3: begin
        nextState = S4;
        enableCounters = T2;
        pedestrianReset = 1'b0;
      end
      S4: begin
        nextState = S0;
        enableCounters = T0;
        pedestrianReset = 1'b1;

      end
    endcase
  end

endmodule

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


module trafficController (
    output wire [2:0] T1,
    T2,
    output wire T1Walk,
    T2Walk,
    T1Buzzer,
    T2Buzzer,
    input clk,
    reset,
    Emergency_Left,
    Emergency_Right,
    T1pedButton,
    T2pedButton
);

  wand nextEventFSM;
  wire enableT1, enableT2, enableT3, enableT0, gatedClock, disableClock;

  assign gatedClock = clk & ~disableClock; //Disable the clock to stop and stay in the currentState, incase of Emergency
  counter #(
      .TIME(5)
  ) TS0 (
      .overflow(nextEventFSM),
      .enable(enableT0),
      .clk(gatedClock),
      .reset(reset)
  );
  counter #(
      .TIME(55)
  ) TS1 (
      .overflow(nextEventFSM),
      .enable(enableT1),
      .clk(gatedClock),
      .reset(reset)
  );
  counter #(
      .TIME(5)
  ) TS2 (
      .overflow(nextEventFSM),
      .enable(enableT2),
      .clk(gatedClock),
      .reset(reset)
  );
  counter #(
      .TIME(30)
  ) TS3 (
      .overflow(nextEventFSM),
      .enable(enableT3),
      .clk(gatedClock),
      .reset(reset)
  );

  wire [2:0] currentState;

  trafficFSM fsm_T1 (
      .currentState(currentState),
      .enableCounters({enableT3, enableT2, enableT1, enableT0}),
      .triggerNextEvent(nextEventFSM),
      .reset(reset),
      .pedButton(T1pedButton)
  );
  trafficSignalDisplay #(
      .TYPE(1)
  ) disp_T1 (
      .currentState(currentState),
      .emergencySignals({Emergency_Left, Emergency_Right}),
      .Signal(T1),
      .Walk(T1Walk),
      .Buzzer(T1Buzzer),
      .reset(reset),
      .clk(clk),
      .disableClock(disableClock)
  );

  wand nextEventFSM_T2;
  wire enableY1, enableY2, enableY3, enableY0, gatedClock_T2, disableClock_T2;

  assign gatedClock_T2 = clk & ~disableClock_T2; //Disable the clock to stop and stay in the currentState, incase of Emergency
  counter #(
      .TIME(5)
  ) YS0 (
      .overflow(nextEventFSM_T2),
      .enable(enableY0),
      .clk(gatedClock_T2),
      .reset(reset)
  );
  counter #(
      .TIME(55)
  ) YS1 (
      .overflow(nextEventFSM_T2),
      .enable(enableY1),
      .clk(gatedClock_T2),
      .reset(reset)
  );
  counter #(
      .TIME(5)
  ) YS2 (
      .overflow(nextEventFSM_T2),
      .enable(enableY2),
      .clk(gatedClock_T2),
      .reset(reset)
  );
  counter #(
      .TIME(30)
  ) YS3 (
      .overflow(nextEventFSM_T2),
      .enable(enableY3),
      .clk(gatedClock_T2),
      .reset(reset)
  );

  wire [2:0] currentState_T2;

  trafficFSM fsm_T2 (
      .currentState(currentState_T2),
      .enableCounters({enableY3, enableY2, enableY1, enableY0}),
      .triggerNextEvent(nextEventFSM_T2),
      .reset(reset),
      .pedButton(T2pedButton)
  );
  trafficSignalDisplay #(
      .TYPE(2)
  ) disp_T2 (
      .currentState(currentState_T2),
      .emergencySignals({Emergency_Left, Emergency_Right}),
      .Signal(T2),
      .Walk(T2Walk),
      .Buzzer(T2Buzzer),
      .reset(reset),
      .clk(clk),
      .disableClock(disableClock_T2)
  );

endmodule
