module trafficFSM(
    output reg[3:0] currentState,
    output reg[1:0] T1,T2,W1,W2, 
    output reg Buzzer,
    input triggerNextEvent, reset, emergency_left, emergency_right);
/*
* This module is the heart of the FSM logic we use in out traffic Controller.
* This is responsible for turning on/off the required counters(TIMERS).
* The currentState Output is responsible for the trafficLights and Walk Lights
* and Buzzer.
*/
reg[3:0] nextState,previousState;
// The FSM has 7 states, 0-4 are the normal states, 5 is for emergency left and 6 is for emergency right
parameter S0 = 4'd0, S1 = 4'd1, S2 = 4'd2, S3 = 4'd3, S4 = 4'd4,
            S5 = 4'd5, S6 = 4'd6;

//The sequential part of the FSM (CurrentState gets changed here at edges)
always @ (posedge triggerNextEvent or posedge reset)begin
    if(reset)begin
        currentState <= S0;
    end
    else if(emergency_left)begin
        previousState <= currentState;
        currentState <= S5;
    end
    else if(emergency_right)begin
        previousState <= currentState;
        currentState <= S6;
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
        S4: nextState = S0;
        s5: nextState = previousState;
        S6: nextState = previousState;
        
    endcase

    // 01 for red light,10 for yellow light, 00 for green light

    case(currentState)

        //55s
        S0: T1 = 2'b01,// red light
            T2 = 2'b01,// red light
            W1 = 2'b00,// green light
            W2 = 2'b00;// green light
            Buzzer = 1'b0;                    // buzzer off
        
        //5s
        S1: T1 = 2'b10,// yellow light
            T2 = 2'b01, // red light
            W1 = 2'b00,// green light
            W2 = 2'b00;// green light
            Buzzer = 1'b1;                    // buzzer on
        
        //30s
        S2: T1 = 2'b00, // green light
            T2 = 2'b01,// red light
            W1 = 2'b01,// red light
            W2 = 2'b01;// red light
            Buzzer = 1'b0;                    // buzzer off
        
        //5s
        S3: T1 = 2'b10,// yellow light
            T2 = 2'b10,//yellow light
            W1 = 2'b01,//red light
            W2 = 2'b01;//red light
            Buzzer = 1'b0;                    // buzzer off
        
        //30s
        S4: T1 = 2'b01,// red light
            T2 = 2'b00,// green light
            W1 = 2'b01,// red light
            W2 = 2'b01;// red light
            Buzzer = 1'b0;                    // buzzer off 
        
        // Emergency left-10s
        S5: T1 = 2'b01,// red light
            T2 = 2'b00,// green light
            W1 = 2'b00,// green light
            W2 = 2'b01;// red light
            Buzzer = 1'b0;                    // buzzer off
        
        // Emergency right-10s
        S6: T1 = 2'b01,// red light 
            T2 = 2'b01,// red light
            W1 = 2'b01,// red light
            W2 = 2'b00;// green light
            Buzzer = 1'b0;                    // buzzer off
        // Default case to avoid latches
        
        default: T1 = 2'b01,// red light
                 T2 = 2'b01,// red light
                 W1 = 2'b01,// red light
                 W2 = 2'b01;// red light
                 Buzzer = 1'b0;                    // buzzer off
    endcase
end

endmodule
