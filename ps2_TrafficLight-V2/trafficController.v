module trafficController (output wire[2:0]T1, T2, output wire T1Walk, T2Walk, T1Buzzer, T2Buzzer, input clk, reset, Emergency_Left, Emergency_Right, T1pedButton, T2pedButton);

    wand nextEventFSM;
    wire enableT1, enableT2, enableT3, enableT0, gatedClock, disableClock;

    assign gatedClock = clk & ~disableClock; //Disable the clock to stop and stay in the currentState, incase of Emergency
    counter #(.TIME(5)) TS0 (.overflow(nextEventFSM), .enable(enableT0), .clk(gatedClock), .reset(reset));
    counter #(.TIME(55)) TS1 (.overflow(nextEventFSM), .enable(enableT1), .clk(gatedClock), .reset(reset));
    counter #(.TIME(5)) TS2 (.overflow(nextEventFSM), .enable(enableT2), .clk(gatedClock), .reset(reset));
    counter #(.TIME(30)) TS3 (.overflow(nextEventFSM), .enable(enableT3), .clk(gatedClock), .reset(reset));

    wire[2:0] currentState;

    trafficFSM fsm_T1 (.currentState(currentState), .enableCounters({enableT3, enableT2, enableT1, enableT0}), .triggerNextEvent(nextEventFSM), .reset(reset), .pedButton(T1pedButton));
    trafficSignalDisplay #(.TYPE(1)) disp_T1
        (.currentState(currentState), .emergencySignals({Emergency_Left, Emergency_Right}), .Signal(T1), .Walk(T1Walk), .Buzzer(T1Buzzer), .reset(reset), .clk(clk),
        .disableClock(disableClock));

    wand nextEventFSM_T2;
    wire enableY1, enableY2, enableY3, enableY0, gatedClock_T2, disableClock_T2;

    assign gatedClock_T2 = clk & ~disableClock_T2; //Disable the clock to stop and stay in the currentState, incase of Emergency
    counter #(.TIME(5)) YS0 (.overflow(nextEventFSM_T2), .enable(enableY0), .clk(gatedClock_T2), .reset(reset));
    counter #(.TIME(55)) YS1 (.overflow(nextEventFSM_T2), .enable(enableY1), .clk(gatedClock_T2), .reset(reset));
    counter #(.TIME(5)) YS2 (.overflow(nextEventFSM_T2), .enable(enableY2), .clk(gatedClock_T2), .reset(reset));
    counter #(.TIME(30)) YS3 (.overflow(nextEventFSM_T2), .enable(enableY3), .clk(gatedClock_T2), .reset(reset));

    wire[2:0] currentState_T2;

    trafficFSM fsm_T2 (.currentState(currentState_T2), .enableCounters({enableY3, enableY2, enableY1, enableY0}), .triggerNextEvent(nextEventFSM_T2), .reset(reset), .pedButton(T2pedButton));
    trafficSignalDisplay #(.TYPE(2)) disp_T2
        (.currentState(currentState_T2), .emergencySignals({Emergency_Left, Emergency_Right}), .Signal(T2), .Walk(T2Walk), .Buzzer(T2Buzzer), .reset(reset), .clk(clk),
        .disableClock(disableClock_T2));

endmodule
