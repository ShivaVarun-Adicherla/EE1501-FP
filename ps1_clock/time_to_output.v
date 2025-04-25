module time_to_output (
    input wire [4:0] hh,
    input wire [5:0] mm,
    input wire [5:0] ss,
    input wire [4:0] DD,
    input wire [3:0] MM,
    input wire [10:0] YYYY,
    input wire [2:0] week,
    input wire [2:0] mode,
    input wire AMPM_24,
    output reg [5:0][3:0] hhmmss,
    output reg [7:0][3:0] ddmmyyyy,
    output reg [2:0][7:0] weekascii,
    output reg AM_mode,
    output reg PM_mode
);
  reg [4:0] hhtemp;

  always @(*) begin
    hhmmss[0] = ss % 10;
    hhmmss[1] = ss / 10;
    hhmmss[2] = mm % 10;
    hhmmss[3] = mm / 10;
    if (AMPM_24 == 0) begin
      AM_mode = 0;
      PM_mode = 0;
      hhtemp  = hh;
    end else begin
      if (hh == 0) begin
        AM_mode = 1;
        hhtemp  = 12;
      end else if (hh < 12) begin
        AM_mode = 1;
        hhtemp  = hh;
      end else if (hh == 12) begin
        AM_mode = 0;
        hhtemp  = hh;
      end else begin
        AM_mode = 0;
        hhtemp  = hh - 12;
      end
      PM_mode = ~AM_mode;

    end
    hhmmss[4] = hhtemp % 10;
    hhmmss[5] = hhtemp / 10;
    case (YYYY)
      11'd2020: ddmmyyyy[3:0] = (mode[2]) ? 16'h0000 : 16'h2020;
      11'd2021: ddmmyyyy[3:0] = (mode[2]) ? 16'h0001 : 16'h2021;
      11'd2022: ddmmyyyy[3:0] = (mode[2]) ? 16'h0002 : 16'h2022;
      11'd2023: ddmmyyyy[3:0] = (mode[2]) ? 16'h0003 : 16'h2023;
      11'd2024: ddmmyyyy[3:0] = (mode[2]) ? 16'h0004 : 16'h2024;
      11'd2025: ddmmyyyy[3:0] = (mode[2]) ? 16'h0005 : 16'h2025;
    endcase
    ddmmyyyy[4] = MM % 10;
    ddmmyyyy[5] = MM / 10;
    ddmmyyyy[6] = DD % 10;
    ddmmyyyy[7] = DD / 10;
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
