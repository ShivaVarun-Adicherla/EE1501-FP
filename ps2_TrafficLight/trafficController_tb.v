`timescale 1s/1ms
module trafficController_tb();
    reg clk, reset;

    trafficController Con (.clk(clk), .reset(reset));
    always #0.5 clk = ~clk;

    initial begin
        $dumpfile("TrafficSeq.vcd");
        $dumpvars(0);
        reset = 1;
        clk = 0;
        #1 reset = 0;
        #1000;
        $finish;
    end
endmodule
