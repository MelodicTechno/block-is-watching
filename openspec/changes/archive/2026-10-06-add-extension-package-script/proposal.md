# Proposal

## Why

扩展目前已能加载运行，但没有打包分发的手段。上传 Chrome Web Store 需要一个以 `manifest.json` 为根、只含运行时文件的 zip 包；手动压缩容易漏文件或把 `openspec/`、`.opencode/` 等无关目录打进去。需要一条可重复、跨平台的打包命令。

## What Changes

- 新增打包脚本：`scripts/package.ps1`（Windows / PowerShell）与 `scripts/package.sh`（Unix / Bash），两者行为一致。
- 脚本从 `manifest.json` 读取 `name` 与 `version`，生成 `dist/<name>-v<version>.zip`。
- zip 根目录直接包含 `manifest.json`（Chrome 加载要求），仅打包运行时文件：`manifest.json`、`content/`、`icons/`、`README.md`；排除 `openspec/`、`.opencode/`、`scripts/`、`dist/` 等。
- 重复执行时覆盖旧产物；缺少 `manifest.json` 或必需运行时文件时以非零退出并给出提示。
- 更新 `README.md`，说明打包命令与产物位置。

## Capabilities

### New Capabilities

- `extension-packaging`: 为扩展生成可上传的 zip 分发包的命令能力（跨平台脚本、产物命名与内容范围、失败处理）。

### Modified Capabilities

（无，本项目此前无主 specs。）

## Impact

- 新增 `scripts/package.ps1`、`scripts/package.sh`。
- 生成物位于 `dist/`（应加入忽略，避免提交）。
- 更新 `README.md`。
- 无运行时依赖、无第三方依赖，不影响扩展本体行为。
