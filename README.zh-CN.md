# Lichii（sw2Fritchii）简体中文汉化版

本仓库是 [Lichii / Eglantine](https://github.com/Djihads80/Eglantine)（基于 Eden、yuzu 的 Nintendo Switch 2 模拟器）的
个人分支，主要工作是**把桌面端界面完整汉化成简体中文**，并提供**开箱即用的 Windows 中文版（.exe）**。

## 下载

Windows 中文版由 GitHub Actions 自动编译、打包，最新产物放在固定页面的 Release 中：

- **中文安装程序**：`lichii-windows-x86_64-zh-cn-setup.exe`
- **免安装压缩包**：`lichii-windows-x86_64-zh-cn.zip`（解压后直接运行 `lichii.exe`）
- 下载地址：<https://github.com/979859675/sw2Fritchii/releases/tag/zh-cn-latest>
- 也可以在该仓库的 **Actions → windows-zh-cn → 最新一次运行 → Artifacts** 中下载同一份文件。

> 运行需要 64 位 Windows 10/11、支持 Vulkan 的显卡。首次启动需要在「设置 → 系统」中安装固件与密钥
> （`prod.keys`、`title.keys`）后，才能加载游戏。安装包与压缩包内的 `eden-cli.exe` 为命令行版本。

### 切换为简体中文

- 首次启动后点击菜单「模拟（Emulation）→ 设置…（Configure，快捷键 Ctrl+,）→ 界面（Ui）」，
  在最下方的「语言：」下拉框中选择 **简体中文**，程序会在点击确定后自动切换到中文界面
  （翻译已编译进程序内部，不依赖语言包文件）；
- 或直接编辑配置文件：默认位于 `%APPDATA%\eden\config\qt-config.ini`；
  如果 `lichii.exe` 所在目录下存在 `user` 文件夹（便携模式），则改 `user\config\qt-config.ini`：
  ```ini
  [UI]
  language=zh_CN
  ```
- 若系统区域设置为中文，程序在 `language` 为空时也会自动加载中文。
- 命令行版可用 `eden-cli --help` 查看参数。

## 汉化了什么

| 位置 | 文件 | 说明 |
| --- | --- | --- |
| 桌面端界面（Qt） | `dist/languages/zh_CN.ts` | 全部 **2097** 条界面文本均为中文，`lrelease` 报告 0 条未翻译 |
| Android 界面（可选） | `src/android/app/src/main/res/values-zh-rCN/strings.xml` | 补齐新版界面缺失的 105 条文本 |
| 安装程序 | `dist/installer.nsi` | 中文版安装包默认简体中文，自带「创建桌面快捷方式」等中文提示 |

桌面端主要补充的内容包括：NUP 转换 / 提取 / 元数据编辑对话框、游戏图标在线查找（SteamGridDB）、
帧生成（LSFG / 光流 / FSR 3）、DLSS 替换选项、GPU 围栏同步、马力欧卡丁车世界推荐设置等全部新功能，
并把沿用旧版 Eden 文案的提示统一改为 Lichii。

翻译遵循以下约定：

- 占位符（`%1`、`%n`）、HTML 标签、快捷键（`&A`）、文件名与路径保持原样；
- 品牌名、格式名（Vulkan、FSR、FXAA、NUP、Amiibo 等）不翻译；
- 选项名称尽量与模拟器内已有译名保持一致（如 `Fast → 高速`、`Accurate → 高精度`、`Handheld → 掌机模式`）。

## 自行编译

本机没有编译环境也没有关系，仓库内置的 GitHub Actions 工作流会完成全部工作
（MSVC + Qt 6.8.3 + `ENABLE_QT_TRANSLATION=ON` + `windeployqt` + NSIS）：

```text
Actions → windows-zh-cn → Run workflow
```

在 Linux 上本地编译桌面端（需 Qt 6、CMake ≥ 3.22、Ninja）：

```bash
cmake -S . -B build -G Ninja \
  -DCMAKE_BUILD_TYPE=Release \
  -DENABLE_QT_TRANSLATION=ON \
  -DYUZU_USE_BUNDLED_SDL3=ON \
  -DCMAKE_PREFIX_PATH=/path/to/Qt/6.8.3/gcc_64
cmake --build build --target yuzu --parallel
```

- `ENABLE_QT_TRANSLATION` 默认是 **OFF**，不开这个选项程序里根本不会有语言选择项，
  补好的 `zh_CN.ts` 也就不会生效。官方发布用的工作流同样没有开启它，所以官方包没有中文界面。
- 修改 `dist/languages/*.ts` 后无需手工生成 `.qm`，CMake 会在编译时调用 `lrelease` 并把结果嵌入可执行文件。

## 更新翻译

```bash
# 从源码重新抽取字符串（新增/修改文本后执行，会保留已有翻译）
lupdate $(find src/yuzu src/qt_common -name '*.cpp' -o -name '*.h' -o -name '*.ui') \
  -source-language en_US -target-language zh_CN -ts dist/languages/zh_CN.ts

# 检查是否还有未翻译条目（应为 0 条 unfinished）
lrelease dist/languages/zh_CN.ts -qm /tmp/zh_CN.qm
```

## 致谢与许可

本项目与上游一致，以 **GPL-3.0-or-later** 发布（见 `LICENSE.txt`）。所有模拟器代码版权归
Eden / Eglantine / yuzu 及其贡献者所有，本仓库仅做界面汉化与打包，未修改模拟核心。
「Nintendo Switch」为任天堂的商标，本项目与任天堂无任何关联；请勿使用本软件运行未经合法途径获得的游戏。
