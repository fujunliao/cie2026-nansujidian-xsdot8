# XSDot8 向量点积扩展

2026 CIE 全国 RISC-V 高水平创新及应用大赛，香山社区应用创新赛道。团队：南苏且集电66。

项目基于昆明湖 V2 最小配置，复用香山向量通路，实现 8 路有符号 int8 点积，并扩展 NEMU 参考模型用于差分验证。验证配置为 `KunminghuV2MinimalConfig`。完整结果写入目标寄存器低 32 位，其余位清零；这是本实现采用的语义约定。

- `docs/`：技术报告、项目说明与环境复现说明。
- `rtl/`、`integration/`：硬件实现、香山及 NEMU 集成补丁。
- `software/`、`model/`、`tests/`、`tools/`：测试程序、参考模型和复现工具。
- `results/`：测试结果摘要和向量加法波形分析数据。完整原始记录与视频另在赛事提交材料中提供。
- `upstream-lock.json`：本项目使用的上游版本。

在 Ubuntu 环境中，按照 `docs/环境搭建与复现.md` 安装依赖。`python3 tools/verify_package.py` 校验此公开目录中的文件；源码准备与构建使用 `tools/prepare_sources.sh` 和 `tools/build_and_test.sh`。请为复现指定不存在的新工程目录。报告中所述的完整本地交付包包含更多历史记录，部分链接和命令需要结合该交付包使用。

项目使用 AI 辅助设计、编码、测试和文档整理。自有代码与上游文件的许可证分别见 `LICENSE` 和 `integration/UPSTREAM-LICENSE-MulanPSL2`。
