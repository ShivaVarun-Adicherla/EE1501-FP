//Using One-Hot encoding to store the state. making a simple FSM that cycles
//from S1->S2->S3->S1...
//Default state is S1.
module sel_3 (
    input wire reset,
    input wire trigger,
    output reg [2:0] state
);
  parameter S1 = 3'b001;
  parameter S2 = 3'b010;
  parameter S3 = 3'b100;
  always @(posedge trigger or posedge reset) begin
    if (reset) state = S1;
    else begin
      case (state)
        S1: state <= S2;
        S2: state <= S3;
        S3: state <= S1;
        default: state <= S1;
      endcase
    end
  end
endmodule
