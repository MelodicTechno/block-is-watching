# Design

## Context

当前项目是零依赖、零构建的 Chrome 扩展，仅有 `manifest.json`、`content/`、`icons/`、`README.md`。动机见 proposal.md - Why；行为要求见 specs/extension-packaging/spec.md。开发环境为 Windows（Node 23、`zip`/`7z` 可用，PowerShell 原生 `Compress-Archive`），目标同时支持 Unix/类 Unix。

## Goals / Non-Goals

**Goals:**

- 用两个行为一致的薄脚本（`scripts/package.ps1`、`scripts/package.sh`）产出可上传的 zip。
- 不引入运行时/第三方依赖，保持项目零依赖特性。
- 打包逻辑简单、可读，产物确定（命名、内容、根结构可预期）。

**Non-Goals:**

- 不做版本号自动递增、git tag、发布到 Chrome Web Store 的自动化。
- 不引入 npm/`package.json`、打包器（webpack/esbuild）或压缩依赖。
- 不生成未压缩的 `dist/unpacked/`（用户已选择仅 zip 上传包）。

## Decisions

### 提供 PowerShell 与 Bash 两个独立脚本，而非单一跨平台脚本

用户要求同时提供 PowerShell 与 Bash 以覆盖跨平台。备选「单一 Node 脚本」需要额外压缩依赖或 shell 调用系统工具，收益不足；备选「仅 PowerShell」在 Unix 上不可用。两个脚本共享同一套打包规则（内容、命名、排除），以文档与命名约定保持一致。

### 使用各平台原生压缩工具，不引入依赖

- PowerShell：`Compress-Archive`（Windows 原生，零依赖）。
- Bash：系统 `zip` 命令（Unix/类 Unix 常见）；若不可用则报错提示安装。

备选「Node + archiver/jszip」会引入依赖，与项目零依赖定位冲突，被排除。

### 先汇集到临时 staging 目录，再整体压缩

为保证「zip 根目录直接是 `manifest.json`」且排除项干净，两个脚本都先把白名单文件（`manifest.json`、`content/`、`icons/`、`README.md`）复制到临时 staging 目录，再对该目录内容打 zip，最后清理 staging。

- 好处：排除规则是「白名单复制」而非「黑名单压缩」，即使 `openspec/`、`.opencode/`、`scripts/`、`dist/` 存在也不会被打入；根结构天然正确。
- 备选「原地压缩 + 排除列表」需逐个排除，易随目录新增而失效，被排除。

### 从 manifest 读取 name 与 version 决定产物名

- PowerShell：`ConvertFrom-Json` 读取。
- Bash：用 `grep`/`sed` 提取 `"name"` 与 `"version"`（避免依赖 `jq`）。
- 产物名统一为 `dist/<name>-v<version>.zip`；`name` 中的空格替换为 `-`，保证文件名安全。

`dist/` 作为生成目录，建议加入忽略文件，避免产物被提交。

### 失败即非零退出

缺少 `manifest.json`、缺少必需目录（`content/`、`icons/`）、压缩工具不可用时，脚本打印明确错误并以非零状态退出，不生成半成品。

## Risks / Trade-offs

- [Bash 环境无 `zip` 命令] → 启动时检测，缺失则提示安装并退出非零。
- [`Compress-Archive` 曾对目录条目处理不一致，可能把 staging 目录名带入路径或产生空目录] → 压缩 staging 内的子项（`staging/*`）而非 staging 目录本身，并在产物生成后校验根目录存在 `manifest.json`。
- [manifest 中 `name` 含中文/空格导致文件名或 Bash 解析问题] → 文件名做安全化（空格转 `-`、去除非安全字符）；Bash 解析用与 `version` 相同的健壮提取方式，仅依赖 `"version"` 字段。
- [两个脚本行为漂移] → 在 README 与脚本内统一约定产物路径命名，任务中加入「两端产物名一致」的验证。
- [重复运行残留旧产物] → 覆盖同名 zip；staging 目录每次运行前清理。
