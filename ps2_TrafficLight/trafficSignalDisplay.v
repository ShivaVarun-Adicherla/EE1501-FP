module trafficSignalDisplay(output reg[2:0]T1, T2, output reg T1Walk, T2Walk, Buzzer, input wire[3:0] currentState);

    parameter S0 = 4'd0, S1 = 4'd1, S2 = 4'd2, S3 = 4'd3, S4 = 4'd4,
            S5 = 4'd5, S6 = 4'd6;

    parameter RED = 3'd1, YELLOW = 3'd2, GREEN = 3'd4; //These are basically a single bus, to set state of single light
    parameter HIGH = 1'b1, LOW = 1'b0;

    always @(*) begin
        case(currentState)
            S0: begin
                T1 = RED;
                T2 = RED;
                T1Walk = HIGH;
                T2Walk = HIGH;
                Buzzer = LOW;
                end
            S1: begin
                T1 = RED;
                T2 = RED;
                T1Walk = HIGH;
                T2Walk = HIGH;
                Buzzer = HIGH;
                end
            S2: begin
                T1 = YELLOW;
                T2 = RED;
                T1Walk = LOW;
                T2Walk = LOW;
                Buzzer = LOW;
                end
            S3: begin
                T1 = GREEN;
                T2 = RED;
                T1Walk = LOW;
                T2Walk = LOW;
                Buzzer = LOW;
                end
            S4: begin
                T1 = YELLOW;
                T2 = YELLOW;
                T1Walk = LOW;
                T2Walk = LOW;
                Buzzer = LOW;
                end
            S5: begin
                T1 = RED;
                T2 = GREEN;
                T1Walk = RED;
                T2Walk = RED;
                Buzzer = LOW;
                end
            S6: begin
                T1 = RED;
                T2 = YELLOW;
                T1Walk = LOW;
                T2Walk = LOW;
                Buzzer = LOW;
                end
            endcase
    end
endmodule
