#!/bin/bash

echo "Command 1 - For Testing Counter"
echo "Command 2 - For Testing trafficFSM"
echo "Command 3 - For Testing trafficController"

read -r -p "Enter a Command (1, 2, or 3): " num

case "$num" in
    1) echo "Testing Counter";
       iverilog counter.v counter_tb.v -o counter_tb;
       ./counter_tb;
       gtkwave counter_tb.vcd;
       rm counter_tb counter_tb.vcd;;
    2) echo "Testing trafficFSM";
       iverilog trafficFSM.v trafficFSM_tb.v -o trafficFSM_tb;
       ./trafficFSM_tb;
       gtkwave trafficFSM_tb.vcd;
       rm trafficFSM_tb trafficFSM_tb.vcd;;
    3) echo "Running trafficController";
       iverilog counter.v trafficController.v trafficFSM.v trafficSignalDisplay.v trafficController_tb.v -o trafficController_tb;
       ./trafficController_tb;
       gtkwave trafficController_tb.vcd;
       rm trafficController_tb trafficController_tb.vcd;;
    *) echo "Invalid choice!" ;;
esac
