module trafficFSM_tb();
    reg nextEvent, reset;
    wire[3:0] out;
    wire[2:0] enableCounters;

    trafficFSM inst1 (.triggerNextEvent(nextEvent), .currentState(out), .reset(reset), .enableCounters(enableCounters));

    always #1 nextEvent = ~nextEvent;
    initial begin
        $dumpfile("trafficFSM_tb.vcd");
        $dumpvars(0);
        reset = 1;
        nextEvent = 0;
        #10 reset = 0;
        #40;
        $finish;
    end
endmodule
