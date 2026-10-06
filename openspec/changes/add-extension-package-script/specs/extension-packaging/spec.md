# Spec Delta

## Purpose

为扩展提供一条跨平台、可重复的命令，将其打包成可直接上传 Chrome Web Store 的 zip 分发包。

## ADDED Requirements

### Requirement: 跨平台打包命令

项目 SHALL 提供行为一致的打包脚本：Windows 使用 PowerShell 脚本，Unix/类 Unix 使用 Bash 脚本，二者接受相同的打包范围与产物规则。

#### Scenario: Windows 使用 PowerShell 打包

- **WHEN** 在 Windows 上从项目根目录运行 PowerShell 打包脚本
- **THEN** 命令成功执行并生成分发包

#### Scenario: Unix 使用 Bash 打包

- **WHEN** 在 Unix/类 Unix 上从项目根目录运行 Bash 打包脚本
- **THEN** 命令成功执行并生成与 PowerShell 脚本命名一致的分发包

### Requirement: 生成可上传的 zip 分发包

打包命令 SHALL 生成 `dist/<name>-v<version>.zip`，其中 `<name>` 与 `<version>` 取自 `manifest.json`；zip 根目录 MUST 直接包含 `manifest.json`（不额外套一层目录）。

#### Scenario: 产物命名取自 manifest

- **WHEN** `manifest.json` 中 `version` 为 `0.1.0`
- **THEN** 生成的分发包路径为 `dist/<name>-v0.1.0.zip`

#### Scenario: 压缩包根目录包含 manifest

- **WHEN** 解压生成的分发包
- **THEN** 其根目录直接存在 `manifest.json`，可被 Chrome 直接加载

### Requirement: 打包内容仅限运行时文件

分发包 SHALL 仅包含运行扩展所需的文件（`manifest.json`、`content/`、`icons/` 及 `README.md`），SHALL 排除 `openspec/`、`.opencode/`、`scripts/`、`dist/` 等项目元数据目录。

#### Scenario: 排除非运行时目录

- **WHEN** 检查生成的分发包内容
- **THEN** 不包含 `openspec/`、`.opencode/`、`scripts/`、`dist/` 中的任何文件

#### Scenario: 包含运行时资源

- **WHEN** 检查生成的分发包内容
- **THEN** 包含 `manifest.json`、`content/` 与 `icons/` 下的全部文件

### Requirement: 打包失败可诊断

当缺少 `manifest.json` 或必需运行时文件时，打包命令 SHALL 以非零状态退出并输出明确错误信息，而不是生成不完整的分发包。

#### Scenario: 缺少 manifest

- **WHEN** 项目根目录不存在 `manifest.json` 且运行打包命令
- **THEN** 命令以非零状态退出并提示缺少 `manifest.json`

#### Scenario: 缺少必需运行时文件

- **WHEN** `content/` 或 `icons/` 等必需目录缺失且运行打包命令
- **THEN** 命令以非零状态退出并指出缺失的路径

### Requirement: 打包可重复执行

重复运行打包命令 SHALL 覆盖既有产物，不因 `dist/` 或同名 zip 已存在而失败。

#### Scenario: 覆盖已有产物

- **WHEN** `dist/` 中已存在上一次生成的同名分发包并再次运行打包命令
- **THEN** 命令成功执行并覆盖旧文件
