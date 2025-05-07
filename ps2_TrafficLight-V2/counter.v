module counter #(
    parameter TIME = 30
) (
    output overflow,
    input  enable,
    clk,
    reset
);

  /*
* This module is like an overflow timer found in many MCUs.
* The basic idea is that the system does something or is
* interupted from it's routine to perform a task, when the
* overflow signal gets a posedge.
*
* WARNING: The reset in this counter is only supposed to
* bring the counter back to a known state. Using it for
* other logic is discouraged, since there's posibility of
* a false edge, if the timing of reset is in such a way
* that the overflow signal was LOW, then the overflow is
* pushed HIGH, since the counter got reset to TIME.
*
* Also be carefull when passing the TIME parameter, due to
* it's  implementation, we will have issues when deaing with
* TIME values less than 3(exclusive).
*/

  reg [$clog2(TIME) - 1:0] count;

  always @(posedge clk, posedge reset) begin
    if (reset) count <= TIME;  //We have TIME here because this state is init state.
    else if (enable) count <= (count - 1 > TIME) ? TIME : count - 1;
  end

  //We will have a posedge when the count rolls over to TIME
  assign overflow = count[$clog2(TIME)-1];
endmodule
