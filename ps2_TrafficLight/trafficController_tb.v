`timescale 1s/1ms
module trafficController_tb();
    reg clk, reset, eLeft, eRight;
    wire[2:0] T1, T2; wire T1Walk, T2Walk, Buzzer;

    trafficController Con (.clk(clk), .reset(reset), .Emergency_Left(eLeft), .Emergency_Right(eRight), .T1(T1), .T2(T2), .T1Walk(T1Walk), .T2Walk(T2Walk), .Buzzer(Buzzer));
    always #0.5 clk = ~clk;

    initial begin
        $dumpfile("trafficController_tb.vcd");
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
