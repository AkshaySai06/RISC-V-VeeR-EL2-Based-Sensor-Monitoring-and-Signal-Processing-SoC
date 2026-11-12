#!/bin/bash
# Shell script to compile and run tests on Synopsys VCS
set -e

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
cd "$SCRIPT_DIR"

echo "=========================================================="
echo " VeeR EL2 SoC Simulation Suite (Synopsys VCS)"
echo "=========================================================="

MODE=${1:-sim}

if [ "$MODE" == "unit" ]; then
    TB=${2:-tb_fir}
    echo "Running unit testbench: $TB"
    vcs -full64 -sverilog -timescale=1ns/1ps -assert svaext -f filelist_unit.f "../tb/unit/${TB}.sv" -o "simv_${TB}"
    "./simv_${TB}" -l "${TB}.log"

elif [ "$MODE" == "unit_all" ]; then
    echo "Running all unit testbenches..."
    make -f Makefile.vcs unit_all

elif [ "$MODE" == "sim" ]; then
    echo "Running full SoC simulation with firmware..."
    vcs -full64 -sverilog -timescale=1ns/1ps -assert svaext -f filelist_soc.f -o simv_soc
    ./simv_soc +HEX_FILE=../sw/main.hex -l soc_sim.log

else
    echo "Usage: ./run_vcs.sh [unit <tb_name> | unit_all | sim]"
    exit 1
fi

