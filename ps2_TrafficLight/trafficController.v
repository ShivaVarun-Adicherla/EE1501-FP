module trafficController (output wire[2:0]T1, T2, output wire T1Walk, T2Walk, Buzzer, input clk, reset, Emergency_Left, Emergency_Right);

    wand nextEventFSM, gatedClock;
    wire enableTS1, enableTS2, enableTS3;

    assign gatedClock = clk & ~(Emergency_Left | Emergency_Right); //Disable the clock to stop, stay in the currentState, incase of Emergency
    counter #(.TIME(55)) TS1 (.overflow(nextEventFSM), .enable(enableTS1), .clk(gatedClock), .reset(reset));
    counter #(.TIME(5)) TS2 (.overflow(nextEventFSM), .enable(enableTS2), .clk(gatedClock), .reset(reset));
    counter #(.TIME(30)) TS3 (.overflow(nextEventFSM), .enable(enableTS3), .clk(gatedClock), .reset(reset));

    wire[3:0] currentState;
    trafficFSM fsm (.currentState(currentState), .enableCounters({enableTS3, enableTS2, enableTS1}), .triggerNextEvent(nextEventFSM), .reset(reset));
    trafficSignalDisplay disp (.currentState(currentState), .emergencySignals({Emergency_Left, Emergency_Right}), .T1(T1), .T2(T2), .T1Walk(T1Walk), .T2Walk(T2Walk), .Buzzer(Buzzer));
endmodule
