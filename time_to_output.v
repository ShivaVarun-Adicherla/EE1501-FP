module time_to_output (
    input wire [4:0] hh,
    input wire [5:0] mm,
    input wire [5:0] ss,
    input wire [4:0] DD,
    input wire [3:0] MM,
    input wire [10:0] YYYY,
    input wire [2:0] week,
    output wire [5:0][3:0] hhmmss,
    output wire [7:0][3:0] ddmmyyyy,
    output reg [2:0][7:0] weekascii
);
  assign hhmmss[0]   = ss % 10;
  assign hhmmss[1]   = ss / 10;
  assign hhmmss[2]   = mm % 10;
  assign hhmmss[3]   = mm / 10;
  assign hhmmss[4]   = hh % 10;
  assign hhmmss[5]   = hh / 10;

  assign ddmmyyyy[0] = YYYY % 10;
  assign ddmmyyyy[1] = (YYYY / 10) % 10;
  assign ddmmyyyy[2] = (YYYY / 100) % 10;
  assign ddmmyyyy[3] = YYYY / 1000;
  assign ddmmyyyy[4] = MM % 10;
  assign ddmmyyyy[5] = MM / 10;
  assign ddmmyyyy[6] = DD % 10;
  assign ddmmyyyy[7] = DD / 10;

  always @(*) begin
    case (week)
      3'd0: weekascii = "SUN";
      3'd1: weekascii = "MON";
      3'd2: weekascii = "TUE";
      3'd3: weekascii = "WED";
      3'd4: weekascii = "THU";
      3'd5: weekascii = "FRI";
      3'd6: weekascii = "SAT";
      default: weekascii = "ERR";
    endcase
  end
endmodule
