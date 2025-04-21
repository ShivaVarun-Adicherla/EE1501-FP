module binary_time_converter (
    input  wire [31:0] t,
    output wire [ 7:0] hh,
    output wire [ 7:0] mm,
    output wire [ 7:0] ss,
    output reg  [ 7:0] DD,
    output reg  [ 7:0] MM,
    output reg  [15:0] YYYY
);
  parameter DAY = 32'd86400;
  parameter HOUR = 32'd3600;
  parameter MINUTE = 32'd60;
  reg  [ 7:0] dayinmonth;
  wire [31:0] days;
  wire [31:0] timeinday, timeinhour;
  reg [31:0] remainingdays;
  assign days = t / DAY + 32'd1;

  assign timeinday = t % DAY;
  assign hh = timeinday / HOUR;

  assign timeinhour = timeinday % HOUR;
  assign mm = timeinhour / MINUTE;

  assign ss = timeinhour % MINUTE;

  always @(*) begin
    YYYY = 16'd2020;
    MM = 8'd1;
    dayinmonth = 8'd31;
    for (remainingdays = days; remainingdays > dayinmonth && dayinmonth != 0;) begin
      remainingdays = remainingdays - dayinmonth;
      MM = MM + 1;
      if (MM == 8'd13) begin
        MM   = 8'd1;
        YYYY = YYYY + 1;

      end

      case (MM)
        7'd1: dayinmonth = 8'd31;
        7'd2: dayinmonth = (YYYY[1:0] == 2'b00) ? 8'd29 : 8'd28;
        7'd3: dayinmonth = 8'd31;
        7'd4: dayinmonth = 8'd30;
        7'd5: dayinmonth = 8'd31;
        7'd6: dayinmonth = 8'd30;
        7'd7: dayinmonth = 8'd31;
        7'd8: dayinmonth = 8'd31;
        7'd9: dayinmonth = 8'd30;
        7'd10: dayinmonth = 8'd31;
        7'd11: dayinmonth = 8'd30;
        7'd12: dayinmonth = 8'd31;
        default: dayinmonth = 7'd00;
      endcase
    end
    DD = remainingdays;
  end

endmodule

