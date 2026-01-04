复现LLBP
1. 环境准备
该项目基于 ChampSim 模拟器。
操作系统：使用 Ubuntu 22.04.1。
编译器：需要支持 C++17 的编译器（如 g++-9 或更高版本）
安装依赖：
```bash
sudo apt-get update
sudo apt-get install build-essential libboost-all-dev
```
2.获取源码与编译
（1）首先克隆仓库并根据 README 的指示进行编译。
```bash
git clone https://github.com/dhschall/LLBP.git
cd LLBP
```
（2）编译 LLBP 版本的 ChampSim，配置分支预测器、L1/L2/L3 缓存层级等
```bash
./build_champsim.sh bimodal hashed_perceptron lru lru lru lru 1
```
3.调整参数（对齐论文参数）
调整llbp.h文件中的accessDelay = 6；
调整llbp.cc文件中HASHVALS的忽略距离 D = 4；
•热身阶段 (Warm-up)：100M (1亿) 条指令 。
•统计阶段 (Statistics)：200M (2亿) 条指令

4.在LLBP下创建traces文件夹，下载要跑的trace数据集（下载地址：https://zenodo.org/records/13133243），本次复现我们只跑了4个traces（NodeApp、TPCC、Twitter、Merced），原论文跑了数百个。

5.基线与 NodeApp 深度复现
运行 NodeApp 的三种模型对比
```bash
./predictor -b tage64kscl --simulate-btb -w 100M -n 200M -i nodeapp.trace.gz > res_node_base.txt 2>&1 &
./predictor -b llbp-timing --simulate-btb -w 100M -n 200M -i nodeapp.trace.gz > res_node_llbp_real.txt 2>&1 &
./predictor -b llbp --simulate-btb -w 100000000 -n 200000000 -i ~/LLBP/traces/nodeapp-nodeapp.champsim.trace.gz > res_node_llbp_0lat.txt 2>&1 &
./predictor -b tage512kscl --simulate-btb -w 100M -n 200M -i nodeapp.trace.gz > res_node_tage512k.txt 2>&1 &
```
（其他的traces命令只需要替换相应的traces数据集的名称和记录结果的txt文件名称即可）
6.创建一个名为 plot_my_fig9.py 的文件，直接把终端里那些 MPKI 绝对值 输入进去，自动计算 Reduction % 并画出和论文 Figure 9 一模一样的柱状图。
（1）安装必要的库（如果还没安装）：
```bash
pip install matplotlib numpy
```
（2）创建文件并运行：
```bash
nano plot_my_fig9.py  # 粘贴代码后 Ctrl+O 保存, Ctrl+X 退出
python3 plot_my_fig9.py
```

