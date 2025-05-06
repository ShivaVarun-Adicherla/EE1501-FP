module trafficFSM_tb();
    reg nextEvent, reset, pedButton;
    wire[2:0] out;
    wire[3:0] enableCounters;

    trafficFSM inst1 (.triggerNextEvent(nextEvent), .currentState(out), .reset(reset), .enableCounters(enableCounters), .pedButton(pedButton));

    always #1 nextEvent = ~nextEvent;
    initial begin
        $dumpfile("trafficFSM_tb.vcd");
        $dumpvars(0);
        reset = 1;
        nextEvent = 0;
        pedButton =  0;
        #2 reset = 0;
        #40 pedButton = 1;

        /*
        * This is to demonstrate that just pushing the button down will not push the
        * FSM to assume that pedestrains left. The reset is done by final state in
        * Pedestrain Sequence.
        */
        #20 pedButton = 0;
        #20;
        $finish;
    end
endmodule
