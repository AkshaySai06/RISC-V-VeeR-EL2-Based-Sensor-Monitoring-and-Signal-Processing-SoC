#!/bin/bash
set -e
export RV_ROOT=$(pwd)/Cores-VeeR-EL2-main
export BUILD_PATH=$(pwd)/core_config
mkdir -p "$BUILD_PATH"

if command -v perl &> /dev/null; then
    echo "Running VeeR EL2 config generator using perl..."
    "$RV_ROOT/configs/veer.config" -target=default \
      -set=build_axi4=1 \
      -set=iccm_enable=0 \
      -set=dccm_enable=0 \
      -set=icache_enable=0 \
      -set=reset_vec=0x00000000 \
      -set=pic_total_int=8
else
    echo "Perl not found, running python generator..."
    python3 scripts/gen_veer_config.py
fi

echo "Core configuration generated in $BUILD_PATH"

