# 卡刀鸡：剑灵怀旧服炎帝版

基于 [TesBot/BNSClassicMacro](https://github.com/TesBot/BNSClassicMacro) 修改的 AutoHotkey v2 剑灵怀旧服卡刀工具。本版新增炎帝低等级基础连招，并保留原项目的气功与召唤模块。

> 本项目是玩家自用的开源修改版，与游戏开发商、运营商及原项目作者无官方关系。使用自动化工具可能违反游戏规则，请自行判断风险。

## 炎帝循环

```text
4 → R → X → C → V → Z → Tab → 4 → R → Z → R → R×5 → T×10
```

- 默认开关键：`F1`
- 操作方式：轻按一次开始，再按一次停止
- 生效窗口：仅当 `BNSR.exe` 位于前台时发送按键
- 默认间隔：普通按键 90 ms，连续 R/T 75 ms
- 适用范围：按当前低等级技能栏制作；技能或键位变化后需要自行调整

## 使用方法

1. 安装 [AutoHotkey v2](https://www.autohotkey.com/)。
2. 下载本仓库源码并解压，双击 `Main.ahk`。
3. 在界面选择“炎帝 / 基础连招（低等级）”，确认启动键为 F1 并保存。
4. 切回游戏后按 F1 开始，再按 F1 停止。

炎帝模块不需要取色。首次启动后，程序会在 `Config` 目录生成本机配置；这些个人配置不会提交到仓库。

## 编译独立 EXE

使用 AutoHotkey v2 自带的 Ahk2Exe，将 `Main.ahk` 选为源文件即可。编译前请保持 `Lib`、`Flows`、`Config`、`pic` 和 `favicon.ico` 的目录结构不变。

## 其他快捷键

| 快捷键 | 功能 |
| --- | --- |
| `Ctrl+R` | 重新加载当前流派配置 |
| `Ctrl+P` | 常规取色（炎帝不需要） |
| `Ctrl+Shift+P` | 特殊取色（部分其他流派使用） |

## 项目结构

```text
Main.ahk                 主入口
Config/JobConfig.ahk     职业与流派列表
Flows/炎帝_基础连招.ahk  炎帝循环
Flows/气功_1系推龙.ahk   原气功模块
Flows/召唤_1系马蜂.ahk   原召唤模块
Lib/                     公共框架与图像处理代码
pic/                     技能识别图片
```

## 来源与授权

- 上游项目：[TesBot/BNSClassicMacro](https://github.com/TesBot/BNSClassicMacro)
- 原项目作者：TesBot 及原项目贡献者
- 炎帝修改版：在上游源码基础上增加炎帝循环、响应优化与中文使用说明
- `ImagePut.ahk` 来源见其文件内声明及 [iseahound/ImagePut](https://github.com/iseahound/ImagePut)

本项目沿用上游仓库的 **GNU General Public License v3.0**。复制、修改和再发布时必须遵守 [LICENSE](LICENSE)。

详细变更见 [CHANGELOG.md](CHANGELOG.md)。
