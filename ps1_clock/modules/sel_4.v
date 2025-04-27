//Using One-Hot encoding to store the state. making a simple FSM that cycles
//from S1->S2->S3->S4->S1...
//Default state is S1.
module sel_4 (
    input wire reset,
    input wire trigger,
    output reg [3:0] state
);
  parameter S1 = 4'b0001;
  parameter S2 = 4'b0010;
  parameter S3 = 4'b0100;
  parameter S4 = 4'b1000;
  always @(posedge trigger or posedge reset) begin
    if (reset) state = S1;
    else begin
      case (state)
        S1: state <= S2;
        S2: state <= S3;
        S3: state <= S4;
        S4: state <= S1;
        default: state <= S1;
      endcase
    end
  end
endmodule
