# 供应链攻击防护

对 npm 生态的包安装启用了发布冷却策略。
新发布的包需要等待 7 天后才能被包管理器安装，用来降低恶意包、被劫持账号发布的新版本、投毒依赖在攻击窗口期内被拉取的概率。

## 当前控制项

| 工具 | 当前版本 | 配置项 | 配置值 | 单位 | 生效冷却时间 |
| --- | --- | --- | --- | --- | --- |
| npm | 11.14.1 | `min-release-age` | `7` | 天 | 7 天 |
| pnpm | 11.1.1 | `minimumReleaseAge` | `10080` | 分钟 | 7 天 |
| Bun | 1.2.17 | `minimumReleaseAge` | `604800` | 秒 | 7 天 |

## 配置位置

### npm

文件：`~/.npmrc`

```ini
min-release-age=7
```

`min-release-age` 需要 npm `11.10.0` 或更新版本。

```bash
npm install -g npm@latest
```

切换 Node 版本后需要重新检查 npm 版本，因为每个 nvm Node 版本都有自己的 npm。

#### 切换 Node 版本后检查 npm：

```bash
nvm use <version>
npm --version
npm config get min-release-age
```


### pnpm

文件：`~/.config/pnpm/config.yaml`

```yaml
minimumReleaseAge: 10080
```

pnpm 的构建脚本审批配置保留在：

```text
~/.config/pnpm/rc
```

当前内容：

```ini
approve-builds=esbuild
```

pnpm v11 的全局可执行文件目录是：

```text
/Users/tony/Library/pnpm/bin
```


### Bun

文件：`~/.bunfig.toml`

```toml
[install]
minimumReleaseAge = 604800
```

## 验证命令

```bash
npm --version
npm config get min-release-age

pnpm --version
pnpm config get minimumReleaseAge --location=global
pnpm bin -g

bun --version
sed -n '1,80p' ~/.bunfig.toml
```

期望结果：

```text
npm: 11.14.1, min-release-age: 7
pnpm: 11.1.1, minimumReleaseAge: 10080, bin: /Users/tony/Library/pnpm/bin
Bun: 1.2.17, minimumReleaseAge: 604800
```
