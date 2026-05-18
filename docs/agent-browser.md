# Agent Browser 安装与使用

Agent Browser 用于让 Pi agent 操作真实浏览器：打开网页、读取页面快照、点击元素、填写表单、截图、下载文件，以及使用浏览器登录态访问网页。

这里包含两层工具：

- `agent-browser`：上游浏览器自动化 CLI。
- `pi-agent-browser-native`：Pi 扩展，把上游 CLI 封装成 Pi 原生 `agent_browser` 工具。

## 安装

推荐使用 npm 全局安装上游 CLI：

```bash
npm install -g agent-browser
agent-browser install
```

然后安装 Pi 扩展：

```bash
pi install npm:pi-agent-browser-native
```

macOS 也可以通过 Homebrew 安装上游 CLI：

```bash
brew install agent-browser
agent-browser install
pi install npm:pi-agent-browser-native
```

Linux 缺少浏览器依赖时使用：

```bash
agent-browser install --with-deps
```

临时试用 Pi 扩展，使用隔离环境启动 Pi：

```bash
pi --no-extensions -e npm:pi-agent-browser-native
```

## 检查安装

```bash
agent-browser --version
pi-agent-browser-doctor
```

`pi-agent-browser-doctor` 会检查：

- `agent-browser` 是否在 `PATH` 上。
- 上游版本是否匹配 wrapper 的基线。
- Pi 配置里是否存在多个重复加载源。

安装或升级后，在 Pi 里执行：

```text
/reload
```

也可以直接重启 Pi。

## Pi 中的基本用法

打开网页：

```json
{ "args": ["open", "https://example.com"] }
```

获取可交互页面快照：

```json
{ "args": ["snapshot", "-i"] }
```

截图到指定文件：

```json
{ "args": ["screenshot", "/tmp/page.png"] }
```

点击 snapshot 里返回的元素引用：

```json
{ "args": ["click", "@e2"] }
```

使用稳定语义定位点击按钮：

```json
{
  "semanticAction": {
    "action": "click",
    "locator": "role",
    "value": "button",
    "name": "Submit"
  }
}
```

## 常用工作流

### 打开网页并截图

在 Pi 中可以直接说：

```text
Use the agent_browser tool to open https://react.dev and take a screenshot.
```

对应工具调用通常是：

```json
{ "args": ["open", "https://react.dev"] }
```

```json
{ "args": ["screenshot", "react-dev-screenshot.png"] }
```

### 打开网页并交互

```json
{ "args": ["open", "https://react.dev"] }
```

```json
{ "args": ["snapshot", "-i"] }
```

然后根据 snapshot 中的 `@eN` 引用继续点击或填写：

```json
{ "args": ["click", "@e3"] }
```

页面跳转、滚动、重新渲染后，重新运行：

```json
{ "args": ["snapshot", "-i"] }
```

### 使用本地浏览器登录态

访问需要登录的网站时，优先在第一次调用里使用 profile：

```json
{ "args": ["--profile", "Default", "open", "https://example.com/account"] }
```

后续调用沿用同一隐式 session。

如果已经启动过普通 session，后来需要切换到 profile，使用 fresh session：

```json
{
  "args": ["--profile", "Default", "open", "https://example.com/account"],
  "sessionMode": "fresh"
}
```

## 注意事项

- `args` 是传给 `agent-browser` 的参数数组，不包含二进制名本身。
- 页面发生跳转、滚动、重新渲染后，旧的 `@eN` 引用可能失效，重新 `snapshot -i`。
- 可见文本或无障碍名称明确时，优先用 `semanticAction` 或 `find`，减少 stale ref。
- 截图、PDF、下载文件会作为 artifact 返回，优先使用返回的绝对路径。
- 需要登录态、cookies、用户数据时，用 `--profile Default`。
- `agent-browser install` 会安装 Chrome for Testing；已有 Chrome、Brave、Playwright、Puppeteer 浏览器也可能被自动识别。
- `pi-agent-browser-native` 只是 Pi wrapper，真正浏览器能力由上游 `agent-browser` 提供。
