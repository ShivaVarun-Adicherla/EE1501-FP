module unix32_to_binary (
    input wire unix_sclk,
    input wire unix_data,
    output wire [27:0] t
);
  // NOTE: Unix Timestamp counts seconds from 1970 JAN 1 UTC. So for normalization, if we subtract total seconds till 2020 JAN 1 UTC, we will get the :wformat we want it in. If we load the number directly into memory using a timestamp, we will get UTC equivalent of it. After that we can apply offsets to have different timezones.
  reg [31:0] unix32;  //SIPO Shift Register
  assign t = unix32 - 18262 * 86400;
  always @(posedge unix_sclk) unix32 <= {unix_data, unix32[31:1]};
endmodule
