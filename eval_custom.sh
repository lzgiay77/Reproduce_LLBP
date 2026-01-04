#!/bin/bash
set -e

# 1. 精确定义你现有的 4 个 trace 文件（去掉后缀）
TRACES="nodeapp-nodeapp benchbase-tpcc benchbase-twitter merced.467915"
TRACE_DIR="./traces"

# 2. 编译最新的执行文件
cmake --build ./build --target predictor -j $(nproc)

OUT=results/
POSTFIX="ae"

# 设置指令数：100M 预热，200M 测量
N_WARM=$(( 100 * 1000000 ))
N_SIM=$(( 200 * 1000000 )) 

FLAGS="--simulate-btb"

# 3. 图 9 所需的四种对比模型
BRMODELS="llbp llbp-timing tage64kscl tage512kscl"

commands=()
for model in $BRMODELS; do
    for fn in $TRACES; do
        # 针对你目录下混杂的后缀格式进行兼容处理
        if [ -f "$TRACE_DIR/$fn.champsim.trace.gz" ]; then
            TRACE=$TRACE_DIR/$fn.champsim.trace.gz
        elif [ -f "$TRACE_DIR/$fn.champsimtrace.gz" ]; then
            TRACE=$TRACE_DIR/$fn.champsimtrace.gz
        else
            echo "警告：未找到 $fn 对应的 trace 文件，跳过。"
            continue
        fi

        OUTDIR="${OUT}/${fn}/"
        mkdir -p $OUTDIR

        # 构建运行指令
        CMD="./build/predictor $TRACE --model ${model} ${FLAGS} -w ${N_WARM} -n ${N_SIM} --output ${OUTDIR}/${model}-${POSTFIX} > $OUTDIR/${model}-${POSTFIX}.txt 2>&1"
        commands+=("$CMD")
    done
done

echo "准备运行 ${#commands[@]} 个仿真任务..."

# 4. 执行仿真
# 如果系统有 parallel 则并行跑，否则排队跑
if command -v parallel >/dev/null 2>&1; then
    parallel --jobs $(nproc) ::: "${commands[@]}"
else
    echo "未检测到 parallel 工具，将依次执行..."
    for cmd in "${commands[@]}"; do
        echo "正在运行: $cmd"
        eval $cmd
    done
fi

wait
echo "仿真全部完成！结果已保存在 'results/' 文件夹中。"
