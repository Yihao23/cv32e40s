#!/bin/bash
set -e -x

(cd /work/third_party_core/cv32e40s/sim/test \
&& make clean \
&& make PREFIX=~/prefix-cellift/riscv/bin/riscv32-unknown-elf-)

(cd /work/cellift-designs/cellift-cv32e40s/cellift/\
&& bash tests.sh --naive_p1)

python3 /work/third_party_core/cv32e40s/sim/patch_input_pp_random_data0.py \
--file import_from_hw_sw_fuzzer/input_0_a.pp.S \
--addr "$NAIVE_PATCH_ADDR" \
--value "$NAIVE_PATCH_VALUE"


(cd /work/third_party_core/cv32e40s/sim/test \
&& make clean \
&& make PREFIX=~/prefix-cellift/riscv/bin/riscv32-unknown-elf-)

(cd /work/cellift-designs/cellift-cv32e40s/cellift/\
&& bash tests.sh --naive_p2)

echo "$NAIVE_PATCH_ADDR"
echo "$NAIVE_PATCH_VALUE"
echo "$NAIVE_ATOM"
bash /work/third_party_core/cv32e40s/sim/compare_retire_cv32e40s.sh \
output_result/out1.trace \
output_result/out2.trace \
--atom "$NAIVE_ATOM" \
--out-dir output_result