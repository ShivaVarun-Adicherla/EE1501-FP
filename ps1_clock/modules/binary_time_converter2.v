module binary_time_converter (
    input  wire [27:0] t,
    output wire [ 4:0] hh,
    output wire [ 5:0] mm,
    output wire [ 5:0] ss,
    output reg  [ 4:0] DD,
    output reg  [ 3:0] MM,
    output reg  [10:0] YYYY,
    output wire [ 2:0] week
);
  parameter DAY = 86400;
  parameter HOUR = 3600;
  parameter MINUTE = 60;
  wire [11:0] days;
  wire [16:0] timeinday, timeinhour;
  reg [11:0] remainingdays;
  assign days = t / DAY;

  assign timeinday = t % DAY;
  assign hh = timeinday / HOUR;

  assign timeinhour = timeinday % HOUR;
  assign mm = timeinhour / MINUTE;

  assign ss = timeinhour % MINUTE;
  // Week to be assigned as SUN=0,MON=1,TUE=2,WED=3,THU=4,FRI=5,SAT=6
  assign week = (3 + days) % 7;
  always @(*) begin
    //Computing YYYY
    YYYY = 0000;
    if (days + 1 <= 366) begin
      YYYY = 2020;
      remainingdays = days;
    end else if (days + 1 <= 366 + 365) begin
      YYYY = 2021;
      remainingdays = days - 366;
    end else if (days + 1 <= 366 + 2 * 365) begin
      YYYY = 2022;
      remainingdays = days - 366 - 365;
    end else if (days + 1 <= 366 + 3 * 365) begin
      YYYY = 2023;
      remainingdays = days - 366 - 2 * 365;
    end else if (days + 1 <= 2 * 366 + 3 * 365) begin
      YYYY = 2024;
      remainingdays = days - 366 - 3 * 365;
    end else if (days + 1 <= 2 * 366 + 4 * 365) begin
      YYYY = 2025;
      remainingdays = days - 2 * 366 - 3 * 365;
    end
    //Computing Month
    if (YYYY == 2020 || YYYY == 2024) begin  // leap years
      if (remainingdays < 31) begin
        MM = 1;
        DD = remainingdays + 1;
      end else if (remainingdays < 60) begin
        MM = 2;
        DD = remainingdays - 31 + 1;
      end else if (remainingdays < 91) begin
        MM = 3;
        DD = remainingdays - 60 + 1;
      end else if (remainingdays < 121) begin
        MM = 4;
        DD = remainingdays - 91 + 1;
      end else if (remainingdays < 152) begin
        MM = 5;
        DD = remainingdays - 121 + 1;
      end else if (remainingdays < 182) begin
        MM = 6;
        DD = remainingdays - 152 + 1;
      end else if (remainingdays < 213) begin
        MM = 7;
        DD = remainingdays - 182 + 1;
      end else if (remainingdays < 244) begin
        MM = 8;
        DD = remainingdays - 213 + 1;
      end else if (remainingdays < 274) begin
        MM = 9;
        DD = remainingdays - 244 + 1;
      end else if (remainingdays < 305) begin
        MM = 10;
        DD = remainingdays - 274 + 1;
      end else if (remainingdays < 335) begin
        MM = 11;
        DD = remainingdays - 305 + 1;
      end else begin
        MM = 12;
        DD = remainingdays - 335 + 1;
      end
    end else begin  // non-leap years
      if (remainingdays < 31) begin
        MM = 1;
        DD = remainingdays + 1;
      end else if (remainingdays < 59) begin
        MM = 2;
        DD = remainingdays - 31 + 1;
      end else if (remainingdays < 90) begin
        MM = 3;
        DD = remainingdays - 59 + 1;
      end else if (remainingdays < 120) begin
        MM = 4;
        DD = remainingdays - 90 + 1;
      end else if (remainingdays < 151) begin
        MM = 5;
        DD = remainingdays - 120 + 1;
      end else if (remainingdays < 181) begin
        MM = 6;
        DD = remainingdays - 151 + 1;
      end else if (remainingdays < 212) begin
        MM = 7;
        DD = remainingdays - 181 + 1;
      end else if (remainingdays < 243) begin
        MM = 8;
        DD = remainingdays - 212 + 1;
      end else if (remainingdays < 273) begin
        MM = 9;
        DD = remainingdays - 243 + 1;
      end else if (remainingdays < 304) begin
        MM = 10;
        DD = remainingdays - 273 + 1;
      end else if (remainingdays < 334) begin
        MM = 11;
        DD = remainingdays - 304 + 1;
      end else begin
        MM = 12;
        DD = remainingdays - 334 + 1;
      end
    end
  end

endmodule

