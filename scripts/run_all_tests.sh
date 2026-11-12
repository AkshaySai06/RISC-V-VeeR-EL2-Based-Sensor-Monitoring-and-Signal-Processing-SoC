#!/bin/bash
# Comprehensive Test Runner and Summary Table Generator per Section 15.2 of Spec v2.0
set -e

# Synopsys VCS and Verdi Environment Defaults
export VCS_HOME=${VCS_HOME:-/home/student/snps_tools_target/vcs/U-2023.03}
export VERDI_HOME=${VERDI_HOME:-/home/student/snps_tools_target/verdi/U-2023.03-SP1}
export PATH=$VCS_HOME/bin:$VERDI_HOME/bin:$PATH
export SNPSLMD_LICENSE_FILE=${SNPSLMD_LICENSE_FILE:-27021@14.139.1.126}

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
REPO_ROOT=$(dirname "$SCRIPT_DIR")
cd "$REPO_ROOT/sim"

declare -a TESTS=(
    "tb_axi4lite_regif"
    "tb_axi4lite_err_slave"
    "tb_axi4_to_axi4lite"
    "tb_axi4lite_interconnect"
    "tb_axi4lite_sram"
    "tb_uart"
    "tb_timer"
    "tb_gpio"
    "tb_i2c"
    "tb_fir"
    "tb_pwm"
)

TOTAL=0
PASSED=0
FAILED=0
declare -A RESULTS

echo "=================================================================="
echo " Starting Full Verification Regression Suite"
echo "=================================================================="

for test in "${TESTS[@]}"; do
    TOTAL=$((TOTAL + 1))
    echo "Compiling and running: $test..."
    
    if vcs -full64 -sverilog -timescale=1ns/1ps -assert svaext +lint=none -f filelist_unit.f "../tb/unit/${test}.sv" -o "simv_${test}" > /dev/null 2>&1; then
        if "./simv_${test}" | grep -q "PASS"; then
            RESULTS["$test"]="PASS"
            PASSED=$((PASSED + 1))
            echo " -> PASS"
        else
            RESULTS["$test"]="FAIL"
            FAILED=$((FAILED + 1))
            echo " -> FAIL"
        fi
    else
        RESULTS["$test"]="COMPILATION ERROR"
        FAILED=$((FAILED + 1))
        echo " -> COMPILATION ERROR"
    fi
done

# Full SoC Simulation
TOTAL=$((TOTAL + 1))
echo "Compiling and running full SoC simulation (tb_soc_top)..."
if vcs -full64 -sverilog -timescale=1ns/1ps -assert svaext +lint=none -debug_access+all -kdb -P ${VERDI_HOME}/share/PLI/VCS/linux64/novas.tab ${VERDI_HOME}/share/PLI/VCS/linux64/pli.a -f filelist_soc.f -o simv_soc > /dev/null 2>&1; then
    if ./simv_soc +HEX_FILE=../sw/main.hex | grep -q "PASS"; then
        RESULTS["tb_soc_top"]="PASS"
        PASSED=$((PASSED + 1))
        echo " -> PASS"
    else
        RESULTS["tb_soc_top"]="FAIL"
        FAILED=$((FAILED + 1))
        echo " -> FAIL"
    fi
else
    RESULTS["tb_soc_top"]="COMPILATION ERROR"
    FAILED=$((FAILED + 1))
    echo " -> COMPILATION ERROR"
fi

echo ""
echo "=================================================================="
echo "                  TEST EXECUTION SUMMARY TABLE                    "
echo "=================================================================="
printf "%-35s | %-15s\n" "Testbench Name" "Status"
echo "------------------------------------------------------------------"
for test in "${TESTS[@]}"; do
    printf "%-35s | %-15s\n" "$test" "${RESULTS[$test]}"
done
printf "%-35s | %-15s\n" "tb_soc_top" "${RESULTS['tb_soc_top']}"
echo "=================================================================="
printf "Total: %d | Passed: %d | Failed: %d\n" "$TOTAL" "$PASSED" "$FAILED"
echo "=================================================================="

if [ "$FAILED" -ne 0 ]; then
    exit 1
fi

exit 0

