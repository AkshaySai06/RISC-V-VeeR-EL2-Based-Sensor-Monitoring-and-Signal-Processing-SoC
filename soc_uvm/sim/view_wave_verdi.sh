#!/bin/bash
# Script to view UART verification waveforms in Synopsys Verdi
export VERDI_HOME=/home/student/snps_tools_target/verdi/U-2023.03-SP1
export PATH=$VERDI_HOME/bin:$PATH
export SNPSLMD_LICENSE_FILE=27021@14.139.1.126
cd "$(dirname "$0")"
echo "Launching Synopsys Verdi with uart_verification.fsdb..."
verdi -full64 -ssf uart_verification.fsdb &
