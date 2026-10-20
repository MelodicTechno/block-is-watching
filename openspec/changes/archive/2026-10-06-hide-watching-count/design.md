# Design

## Context

全新项目，当前仓库仅包含 `openspec/` 规划目录，无任何扩展代码。目标是构建一个最小化的 Chrome 扩展，仅在 B 站视频页隐藏「xx人正在观看」显示。动机见 proposal.md - Why；行为要求见 specs/watching-count-hiding/spec.md。

## Goals / Non-Goals

**Goals:**

- 在 `www.bilibili.com/video/*` 页面可靠隐藏观看人数显示，覆盖首次加载与后续动态渲染。
- 扩展体积最小、无数据收集、无网络请求、无用户交互。
- 结构清晰、便于后续扩展（如增加开关或覆盖更多页面）。

**Non-Goals:**

- 不处理直播间的「xx人正在观看」（不同页面与结构）。
- 不提供设置页 / 开关 UI（首版自动生效）。
- 不隐藏其它页面元素，不做任何数据统计。

## Decisions

### 使用 Manifest V3

Chrome 已弃用 V2，新扩展一律采用 MV3，支持未来版本的稳定运行。备选 V2 被排除。

### 通过 content script 声明式注入

在 manifest 中声明对 `*://www.bilibili.com/video/*` 的 content script，Chrome 在匹配页面自动注入，无需后台脚本按需注入。备选方案「background service worker + 编程式注入」会增加复杂度且无收益，故不采用。

### 以「文本匹配 + MutationObserver」为主，CSS 注入为辅

B 站 DOM 结构会频繁变更，固定 class 选择器易失效。因此：

- 主策略：content script 用 `MutationObserver` 监听 DOM 变化，检测文本包含「正在观看」的叶子节点，向上找到合适的容器元素并隐藏。
- 辅助策略：在 `document_start` 注入一段 CSS，用「文本内容」无法通过 CSS 直接选择，故 CSS 仅作为对已知 class 的快速兜底（best-effort），尽量减小首帧闪烁。

备选方案「纯固定 CSS 选择器」因脆弱被排除；「纯文本扫描（无 observer）」无法覆盖异步插入，被排除。

### 隐藏方式使用 `display: none`

对目标容器应用 `display: none`（内联样式或专用 class），确保不可见且不占位。相比 `visibility: hidden`，`display: none` 不保留占位空间，符合「隐藏」预期。

### 权限最小化

仅声明 `content_scripts` 所需的匹配权限，不申请 `storage`、`tabs`、`host_permissions` 之外的任何权限，不收集数据。

## Risks / Trade-offs

- [B 站 DOM/class 变更导致文本匹配失效] → 以「正在观看」文本为锚点而非 class，配合 MutationObserver 持续监控；如未来锚点文案变化需更新匹配关键词。
- [首帧短暂显示观看人数（闪烁）] → `document_start` 注入 CSS 兜底已知选择器，尽量提前隐藏。
- [误伤含「正在观看」文本的其它元素] → 限定在视频页并向上收敛到合理的容器节点，必要时校验容器层级，避免隐藏过多。
- [B 站页面结构未知、无法本地验证] → 采用文本锚点方案最大化容错；实现后需在真实页面手动验证并补充测试说明。

## Migration Plan

无历史版本。开发阶段通过 `chrome://extensions` →「加载已解压的扩展程序」加载验证；发布时打包为 zip 上传 Chrome Web Store（可选，超出本变更范围）。

## Open Questions

- 是否需要在后续版本覆盖直播间或 B 站其它域（如 `bilibili.com` 子域）—— 属于可延后的范围扩展，不影响当前 spec 与任务拆分。
