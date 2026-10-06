# Block is watching for Bilibili

一个最小化的 Chrome 扩展（Manifest V3），在 B 站视频播放页自动隐藏右上角的「xx人正在观看」实时观看人数显示，让观看更专注。

## 功能

- 打开 `www.bilibili.com/video/*` 视频页时，自动隐藏「xx人正在观看」显示，无需任何手动操作。
- 覆盖页面初次加载、异步动态插入、站内切换视频（SPA 路由）等场景。
- 不收集任何数据，不发起任何网络请求，不申请多余权限。

## 安装（开发者模式加载）

1. 打开 Chrome，地址栏输入 `chrome://extensions` 回车。
2. 打开右上角的「开发者模式」。
3. 点击「加载已解压的扩展程序」。
4. 选择本项目根目录（包含 `manifest.json` 的目录）。
5. 打开任意 B 站视频页，确认右上角不再显示「xx人正在观看」。

更新代码后，在 `chrome://extensions` 中点击该扩展的刷新按钮，然后刷新视频页即可。

## 使用效果

- 视频页：观看人数显示被隐藏，其它内容不受影响。
- 非视频页（首页等）：扩展不注入、不修改任何元素。

## 目录结构

```
manifest.json        扩展清单（MV3）
content/
  content.js         文本锚点扫描 + MutationObserver + 路由监听
  content.css        已知观看人数容器 class 的兜底隐藏
icons/               扩展图标
```

## 工作原理

- 匹配范围仅 `*://www.bilibili.com/video/*`，由 manifest 声明，非视频页不会注入脚本。
- `content.js` 以文本「正在观看」为锚点查找元素，向上收敛到合理的容器并设置 `display: none`。
- `MutationObserver` 监听 DOM 变化，处理异步渲染与站内导航，持续保持隐藏。
- `content.css` 在 `document_start` 注入，对已知容器 class 做兜底隐藏，减少首帧闪烁。

## 局限

- 直播间及其它页面不在本扩展范围内。
- 若 B 站锚点文案（「正在观看」）变更，需要同步更新 `content/content.js` 中的关键词。
