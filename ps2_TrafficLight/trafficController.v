module trafficController (input clk, reset);

    wand nextEventFSM;
    wire enableTS1, enableTS2, enableTS3;

    counter #(.TIME(55)) TS1 (.overflow(nextEventFSM), .enable(enableTS1), .clk(clk), .reset(reset));
    counter #(.TIME(5)) TS2 (.overflow(nextEventFSM), .enable(enableTS2), .clk(clk), .reset(reset));
    counter #(.TIME(30)) TS3 (.overflow(nextEventFSM), .enable(enableTS3), .clk(clk), .reset(reset));

    wire[3:0] currentState;
    trafficFSM fsm (.currentState(currentState), .enableCounters({enableTS3, enableTS2, enableTS1}), .triggerNextEvent(nextEventFSM), .reset(reset));
endmodule
