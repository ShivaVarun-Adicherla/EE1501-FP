`timescale 1s/1ms
module trafficController_tb();
    reg clk, reset, eLeft, eRight, T1pedButton, T2pedButton;
    wire[2:0] T1, T2; wire T1Walk, T2Walk, T1Buzzer, T2Buzzer;

    trafficController Con (.clk(clk), .reset(reset), .Emergency_Left(eLeft), .Emergency_Right(eRight), .T1(T1), .T2(T2), .T1Walk(T1Walk), .T2Walk(T2Walk), .T1Buzzer(T1Buzzer), .T2Buzzer(T2Buzzer), .T1pedButton(T1pedButton), .T2pedButton(T2pedButton));
    always #0.5 clk = ~clk;

    initial begin
        $dumpfile("trafficController_tb.vcd");
        $dumpvars(0);
        reset = 1;
        clk = 0;
        eLeft = 0;
        eRight = 0;
        T1pedButton = 0;
        T2pedButton = 0;

        #1 reset = 0;
        #30 T1pedButton = 1;
        T2pedButton = 1;
        #2 T1pedButton = 0;
        T2pedButton = 0;

        eLeft = 1;
        #2 eLeft = 0;

        #40;

        eRight = 1;
        #2 eRight = 0;

        #400;
        $finish;
    end
endmodule
