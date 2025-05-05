module trafficFSM(output reg[3:0] currentState, output reg[2:0] enableCounters, input triggerNextEvent, reset);
/*
* This module is the heart of the FSM logic we use in out traffic Controller.
* This is responsible for turning on/off the required counters(TIMERS).
* The currentState Output is responsible for the trafficLights and Walk Lights
* and Buzzer.
*/
reg[3:0] nextState;
parameter S0 = 4'd0, S1 = 4'd1, S2 = 4'd2, S3 = 4'd3, S4 = 4'd4,
            S5 = 4'd5, S6 = 4'd6;

//The sequential part of the FSM (CurrentState gets changed here at edges)
always @ (posedge triggerNextEvent or posedge reset)begin
    if(reset)begin
        currentState <= S0;
    end
    else begin
        currentState <= nextState;
    end
end

//The Combinational part of FSM (nextState gets predicted here)
always @ (*) begin

    case(currentState)
        S0: nextState = S1;
        S1: nextState = S2;
        S2: nextState = S3;
        S3: nextState = S4;
        S4: nextState = S5;
        S5: nextState = S6;
        S6: nextState = S0;
    endcase
    /*
    * The LSB is the enable for TS1 Counter, with the middle bit being
    * enable for the TS2 Counter and so on. You should get the idea :)
    */
    case(currentState)
        S0: enableCounters = 3'b001;
        S1: enableCounters = 3'b010;
        S2: enableCounters = 3'b010;
        S3: enableCounters = 3'b100;
        S4: enableCounters = 3'b010;
        S5: enableCounters = 3'b100;
        S6: enableCounters = 3'b010;
    endcase
end

endmodule
