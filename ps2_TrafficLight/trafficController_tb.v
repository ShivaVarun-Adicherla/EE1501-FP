`timescale 1s/1ms
module trafficController_tb();
    reg clk, reset, eLeft, eRight;

    trafficController Con (.clk(clk), .reset(reset), .Emergency_Left(eLeft), .Emergency_Right(eRight));
    always #0.5 clk = ~clk;

    initial begin
        $dumpfile("TrafficSeq.vcd");
        $dumpvars(0);
        reset = 1;
        clk = 0;
        eLeft = 0;
        eRight = 0;

        #1 reset = 0;
        #300;

        eLeft = 1;
        #20 eLeft = 0;

        #30;

        eRight = 1;
        #20 eRight = 0;
        $finish;
    end
endmodule
