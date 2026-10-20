# Proposal

## Why

B 站视频播放页右上角会显示「xx人正在观看」（实时观看人数）。该信息并非所有用户都希望看到，可能带来从众心理、干扰观看或引发焦虑。此扩展用于在 B 站视频页自动隐藏这一显示，让用户专注于内容本身。

## What Changes

- 新增一个 Chrome 扩展（Manifest V3），在 B 站视频页（`www.bilibili.com/video/*`）自动隐藏「xx人正在观看」元素。
- 通过 content script 定位并隐藏该元素（`display: none`），无需用户手动操作。
- 扩展保持最小化：仅包含 manifest、content script 与必要的样式逻辑，不收集任何数据、不注入任何网络请求。

## Capabilities

### New Capabilities

- `watching-count-hiding`: 在 B 站视频页自动隐藏「xx人正在观看」观看人数显示的核心能力。

### Modified Capabilities

（无，这是全新项目，暂无已有 spec。）

## Impact

- 新建 Chrome 扩展项目文件：`manifest.json`、content script（JS）、可选 CSS、图标等。
- 无后端、无第三方依赖、无数据收集。
- 仅影响 B 站视频页 DOM 展示，不影响 B 站其它功能。
