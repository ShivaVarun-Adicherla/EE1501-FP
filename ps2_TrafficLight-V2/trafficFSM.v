module trafficFSM(output reg[2:0] currentState, output reg[3:0] enableCounters, input triggerNextEvent, reset, pedButton);

reg[2:0] nextState;
parameter S0 = 3'd0, S1 = 3'd1, S2 = 3'd2, S3 = 3'd3, S4 = 3'd4;
parameter T3 = 4'b1000, T0 = 4'b0001, T1 = 4'b0010, T2 = 4'b0100;

reg pedestrianPresent, pedestrianReset;
always @(posedge pedButton, posedge pedestrianReset) begin
    if(pedestrianReset)
        pedestrianPresent <= 1'b0;
    else if(pedButton)
        pedestrianPresent <= 1'b1;
end

//The sequential part of the FSM (CurrentState gets changed here at edges)
always @ (posedge triggerNextEvent or posedge reset)begin
    if(reset)begin
        currentState <= S0;
        pedestrianPresent <= 1'b0;
        pedestrianReset <= 1'b0;
    end
    else begin
        currentState <= nextState;
    end
end

//The Combinational part of FSM (nextState gets predicted here)
always @ (*) begin
    casez(currentState)
        S0:begin
            if(pedestrianPresent)
                nextState = S1;
            else
                nextState = S0;

            enableCounters = T3;
        end
        S1:begin
            nextState = S2;
            enableCounters = T0;
        end
        S2:begin
            nextState = S3;
            enableCounters = T1;
        end
        S3:begin
            nextState = S4;
            enableCounters = T2;
        end
        S4:begin
            nextState = S0;
            enableCounters = T0;
        end
    endcase
end

endmodule
