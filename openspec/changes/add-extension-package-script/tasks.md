# Tasks

## 1. PowerShell 打包脚本

- [ ] 1.1 实现 `scripts/package.ps1`：从 `manifest.json` 读取 `name`/`version`，将白名单文件（`manifest.json`、`content/`、`icons/`、`README.md`）复制到临时 staging 目录后压缩，输出 `dist/<name>-v<version>.zip`（`name` 空格转 `-`）；验证方式：在项目根目录运行 `pwsh scripts/package.ps1` 退出码为 0，且 `dist/` 下生成对应 zip
- [ ] 1.2 实现失败即非零退出：缺少 `manifest.json`、缺少 `content/` 或 `icons/` 时打印明确错误并以非零状态退出，不生成半成品；验证方式：在缺少 `manifest.json` 的临时目录运行脚本，退出码非零且输出指明缺失项
- [ ] 1.3 为脚本添加用法/帮助输出；验证方式：运行 `pwsh scripts/package.ps1 -?`（或帮助分支）显示命令用法与产物路径说明

## 2. Bash 打包脚本

- [ ] 2.1 实现 `scripts/package.sh`：采用与 PowerShell 一致的白名单 staging、产物命名与失败处理，使用系统 `zip`；验证方式：`bash -n scripts/package.sh` 语法检查通过，且在有 `bash`+`zip` 的环境运行生成 zip
- [ ] 2.2 验证两端行为一致：对同一 `manifest.json` 分别运行两个脚本，产物文件名相同、解压后文件清单一致；验证方式：比较两次生成的 zip 文件名并列出/对比解压内容
- [ ] 2.3 实现 Bash 端失败处理：缺少 `manifest.json`/必需目录或 `zip` 不可用时非零退出并提示；验证方式：模拟缺失目录或无 `zip` 场景，确认退出码非零且有明确提示

## 3. 文档与仓库卫生

- [ ] 3.1 更新 `README.md`，新增打包章节（PowerShell 与 Bash 命令、产物路径与命名规则、非运行时目录会被排除）；验证方式：按 README 中的命令执行，成功得到所述产物
- [ ] 3.2 新增 `.gitignore` 忽略 `dist/` 与脚本临时 staging 目录；验证方式：检查 `.gitignore` 内容包含 `dist/`，且脚本运行后 `dist/` 不会出现在版本控制候选中

## 4. 集成验证

- [ ] 4.1 解压生成的 zip，确认根目录直接含 `manifest.json`、仅包含白名单文件（不含 `openspec/`、`.opencode/`、`scripts/`、`dist/`），且该结构可被 Chrome 以「加载已解压的扩展程序」正常加载；验证方式：解压后列目录核对并加载扩展无报错
- [ ] 4.2 连续运行打包命令两次，确认覆盖旧产物且可重复执行；验证方式：第二次运行退出码为 0，产物被更新且解压内容一致

## Workflow follow-up

- 在项目评审要求满足后归档本变更。
- 归档后校验结果。
