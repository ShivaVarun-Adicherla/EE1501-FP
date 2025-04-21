module top_module (
    input wire mode,
    input wire up,
    input wire down,
    input wire select,
    input wire reset,
    output [5:0][3:0] hhmmss,
    output [7:0][3:0] ddmmyyyy,
    output AM_mode,
    output PM_mode,
    output timer_buzzer,
    output alarm_buzzer
);
endmodule
