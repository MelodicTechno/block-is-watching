# Tasks

## 1. 扩展骨架与加载

- [x] 1.1 创建 `manifest.json`（Manifest V3），声明 `content_scripts` 匹配 `*://www.bilibili.com/video/*`、`run_at: document_start`、并引入 `content/content.css` 与 `content/content.js`；验证方式：`manifest.json` 可被 JSON 解析，且 `manifest_version`、`content_scripts.matches`、`run_at` 字段齐全
- [x] 1.2 创建目录结构 `content/`（含 `content.js`、`content.css`）与 `icons/`（含占位图标）；验证方式：目录与文件均已存在且被 manifest 正确引用
- [x] 1.3 编写 `README.md`，说明加载方式（`chrome://extensions` →「加载已解压的扩展程序」）与使用效果；验证方式：按 README 步骤操作可成功加载扩展
- [x] 1.4 在 `chrome://extensions` 加载已解压扩展；验证方式：扩展加载无错误/警告，且在视频页 content script 被注入（可在 Console 中确认脚本已执行）

## 2. 核心隐藏逻辑

- [x] 2.1 在 `content.js` 中实现文本锚点扫描：查找文本包含「正在观看」的叶子节点，向上收敛到合理的容器元素，并对其设置 `display: none`；验证方式：打开任一 B 站视频页后「xx人正在观看」元素不可见
- [x] 2.2 在 `content.css` 中为已知「正在观看」容器 class 添加 `display: none` 兜底规则，配合 `document_start` 注入以减小首帧闪烁；验证方式：强刷视频页时观看人数无明显闪现
- [x] 2.3 将隐藏逻辑封装为可重复调用的函数（供初始执行与后续 DOM 变化复用）；验证方式：初始加载即隐藏，且函数可被重复调用而不报错

## 3. 动态渲染与 SPA 处理

- [x] 3.1 使用 `MutationObserver` 监听 DOM 变化，在「正在观看」元素于初始加载后异步插入时再次执行隐藏；验证方式：模拟/等待元素延迟出现后仍被隐藏
- [x] 3.2 处理 B 站站内导航（SPA 路由切换）场景，确保切换视频后新页面的观看人数同样被隐藏；验证方式：在同一标签页内先后打开两个不同视频，两次均无观看人数显示

## 4. 边界与权限验证

- [x] 4.1 验证非视频页（如 B 站首页或其它非 `www.bilibili.com/video/*` 页面）不受影响；验证方式：打开首页，确认扩展未修改任何页面元素
- [x] 4.2 验证不会误伤其它含「正在观看」文本的元素，必要时校验容器层级以收敛隐藏范围；验证方式：在视频页确认仅观看人数显示被隐藏，其它内容正常
- [x] 4.3 核对权限最小化：`manifest.json` 未申请 `storage`、`tabs`、`host_permissions` 等非必需权限，且无任何网络请求或数据收集；验证方式：审查 manifest 权限声明与 `content.js`/`content.css` 内容，确认仅有 content script 所需匹配

## Workflow follow-up

- 在项目评审要求满足后归档本变更。
- 归档后校验结果。
