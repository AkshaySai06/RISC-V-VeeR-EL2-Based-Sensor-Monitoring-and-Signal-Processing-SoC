#!/bin/bash
# Script to view UART verification waveforms in Synopsys DVE
export VCS_HOME=/home/student/snps_tools_target/vcs/U-2023.03
export PATH=$VCS_HOME/bin:$PATH
export SNPSLMD_LICENSE_FILE=27021@14.139.1.126
cd "$(dirname "$0")"
echo "Launching Synopsys DVE with uart_verification.vpd..."
dve -full64 -vpd uart_verification.vpd &
