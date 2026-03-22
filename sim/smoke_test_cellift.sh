#!/bin/bash
set -e -x

cd /work/third_party_core/cv32e40s/sim/test \
&& make clean \
&& make PREFIX=~/prefix-cellift/riscv/bin/riscv32-unknown-elf-

: <<'COMMENT'
cd /work/third_party_core/cv32e40s/sim \
&& PATH=~/prefix-cellift/bin:$PATH make clean \
&& PATH=~/prefix-cellift/bin:$PATH make

 cd /work/third_party_core/cv32e40s/sim && cp test/firmware.hex . \
 && LD_LIBRARY_PATH=~/prefix-cellift/lib64 ./obj_dir/Vtb_top +trace
COMMENT

cd /work/cellift-designs/cellift-cv32e40s/cellift/\
&& bash tests.sh