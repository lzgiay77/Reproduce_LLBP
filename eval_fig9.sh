#!/bin/bash
set -e

# 1. 目标 Trace (基于你目录下的实际文件名)
TRACES="nodeapp-nodeapp benchbase-tpcc benchbase-twitter merced.467915"
TRACE_DIR="./traces"

# 2. 编译
cmake --build ./build --target predictor -j $(nproc)

OUT=results/
POSTFIX="ae"
N_WARM=$(( 100 * 1000000 ))
N_SIM=$(( 200 * 1000000 )) 

FLAGS="--simulate-btb"

# 3. 严格对应 Figure 9 的四个核心模型
# tage64kscl: 基准线 (图中 0% 的位置)
# llbp-timing: 图中的 "LLBP" (深绿色柱子)
# llbp: 图中的 "LLBP-0Lat" (中绿色柱子)
# tage512kscl: 图中的 "512K TSL" (浅蓝色柱子)
BRMODELS="tage64kscl llbp-timing llbp tage512kscl"

commands=()
for model in $BRMODELS; do
    for fn in $TRACES; do
        if [ -f "$TRACE_DIR/$fn.champsim.trace.gz" ]; then
            TRACE=$TRACE_DIR/$fn.champsim.trace.gz
        elif [ -f "$TRACE_DIR/$fn.champsimtrace.gz" ]; then
            TRACE=$TRACE_DIR/$fn.champsimtrace.gz
        else
            continue
        fi

        OUTDIR="${OUT}/${fn}/"
        mkdir -p $OUTDIR

        CMD="./build/predictor $TRACE --model ${model} ${FLAGS} -w ${N_WARM} -n ${N_SIM} --output ${OUTDIR}/${model}-${POSTFIX} > $OUTDIR/${model}-${POSTFIX}.txt 2>&1"
        commands+=("$CMD")
    done
done

echo "正在启动图 9 复现实验：共 16 个任务 (4模型 x 4Trace)..."
if command -v parallel >/dev/null 2>&1; then
    parallel --jobs $(nproc) ::: "${commands[@]}"
else
    for cmd in "${commands[@]}"; do echo "执行中: $cmd"; eval $cmd; done
fi

wait
echo "仿真结束！数据已存入 ~/LLBP/results/ 目录。"
