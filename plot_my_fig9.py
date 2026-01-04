import matplotlib.pyplot as plt
import numpy as np

# 1. 填入从终端 grep 出来的 ROI MPKI 数据
# 数据来源：终端输出
data = {
    'NodeApp': {
        'base': 4.4319,
        'llbp_real': 3.4860,
        'llbp_0lat': 3.3182,
        'tage512k': 2.3897
    },
    'TPCC': {
        'base': 3.7616,
        'llbp_real': 3.3855,
        'llbp_0lat': 3.2995,
        'tage512k': 2.5159
    },
    'Twitter': {
        'base': 3.0476,
        'llbp_real': 2.9909,
        'llbp_0lat': 2.9251,
        'tage512k': 2.5209
    },
    'Merced': {
        'base': 4.0806,
        'llbp_real': 3.5879,
        'llbp_0lat': 3.5184,
        'tage512k': 2.5851
    }
}

# 2. 计算 Reduction % (公式: (Base - Target) / Base * 100)
benchmarks = list(data.keys())
llbp_real_red = [((v['base'] - v['llbp_real']) / v['base'] * 100) for v in data.values()]
llbp_0lat_red = [((v['base'] - v['llbp_0lat']) / v['base'] * 100) for v in data.values()]
tage512k_red = [((v['base'] - v['tage512k']) / v['base'] * 100) for v in data.values()]

# 3. 绘图设置 (对齐论文风格)
x = np.arange(len(benchmarks))
width = 0.25

fig, ax = plt.subplots(figsize=(10, 5))

# 绘制三组柱子
rects1 = ax.bar(x - width, llbp_real_red, width, label='LLBP', color='#06331a', edgecolor='black')
rects2 = ax.bar(x, llbp_0lat_red, width, label='LLBP-0Lat', color='#326161', edgecolor='black')
rects3 = ax.bar(x + width, tage512k_red, width, label='512K TSL', color='#d3e8eb', edgecolor='black')

# 装饰图表
ax.set_ylabel('Branch MPKI Reduction [%]', fontsize=12)
ax.set_title('Reproduction of Figure 9: Branch Misprediction Reduction over 64K TSL', fontsize=14)
ax.set_xticks(x)
ax.set_xticklabels(benchmarks)
ax.legend()
ax.grid(axis='y', linestyle='--', alpha=0.7)

# 在柱子上方标注数值 (可选)
def autolabel(rects):
    for rect in rects:
        height = rect.get_height()
        ax.annotate(f'{height:.1f}%',
                    xy=(rect.get_x() + rect.get_width() / 2, height),
                    xytext=(0, 3), textcoords="offset points",
                    ha='center', va='bottom', fontsize=8)

autolabel(rects1)
autolabel(rects2)
autolabel(rects3)

plt.tight_layout()
plt.savefig('my_figure9.png') # 保存为图片
print("图表已生成：my_figure9.png")
plt.show()
