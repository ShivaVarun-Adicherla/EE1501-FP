#!/bin/bash

# Find all *_tb.v files
tb_files=($(find . -maxdepth 1 -name "*_tb.v"))

# Check if there are any tb files
if [ ${#tb_files[@]} -eq 0 ]; then
    echo "No *_tb.v files found."
    exit 1
fi

# Display menu
echo "Select a testbench file to run:"
for i in "${!tb_files[@]}"; do
    echo "$((i+1)). ${tb_files[$i]}"
done

# Read user choice
read -p "Enter choice number: " choice

# Validate input
if ! [[ "$choice" =~ ^[0-9]+$ ]] || [ "$choice" -lt 1 ] || [ "$choice" -gt "${#tb_files[@]}" ]; then
    echo "Invalid choice."
    exit 1
fi

# Get the selected file
tb_file="${tb_files[$((choice-1))]}"

# Remove ./ from the file path if present
tb_file_name=$(basename "$tb_file" .v)

# Compile
echo "Compiling $tb_file..."
iverilog -o a.out "$tb_file" modules/*.v
if [ $? -ne 0 ]; then
    echo "Compilation failed."
    exit 1
fi

# Run simulation
echo "Running simulation..."
./a.out
if [ $? -ne 0 ]; then
    echo "Simulation failed."
    exit 1
fi

# Open GTKWave
if [ -f simout.vcd ]; then
    echo "Opening GTKWave..."
    gtkwave simout.vcd
else
    echo "simout.vcd not found. Simulation may have failed to generate VCD."
fi

