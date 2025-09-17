# mac(brew)
```
brew install yazi ffmpeg sevenzip jq poppler fd ripgrep fzf zoxide resvg imagemagick font-symbols-only-nerd-font
```

# Ubuntu

# 如果系统没装 file，Yazi 拿不到 MIME 类型就不会触发对应的预览器，右侧就看不到文件预览
```bash
sudo apt update
sudo apt install -y file
```

## 可选依赖
```bash
sudo apt update
sudo apt install -y ffmpeg 7zip jq poppler-utils fd-find ripgrep fzf zoxide imagemagick
```

## 下载官方安装好的
由于 Ubuntu 20.04 只有 glibc 2.31，而 yazi 的 linux-gnu 官方二进制现在需要 GLIBC 2.39，所以会报错。
解决办法是用官方提供的 linux-musl 构建（不依赖系统 glibc），它适合 20.04。

安装到 /usr/local/bin
```bash
TMPDIR="$(mktemp -d)" && \
arch="$(uname -m)" && { case "$arch" in x86_64) arch="x86_64-unknown-linux-musl" ;; aarch64|arm64) arch="aarch64-unknown-linux-musl" ;; *) echo "unsupported arch: $arch"; rm -rf "$TMPDIR"; exit 1 ;; esac; } && \
tag="$(curl -fsSLI -o /dev/null -w '%{url_effective}' https://github.com/sxyazi/yazi/releases/latest | awk -F/ '{print $NF}')" && \
{ curl -fL "https://github.com/sxyazi/yazi/releases/download/${tag}/yazi-${arch}.zip" -o "$TMPDIR/yazi.zip" || curl -fL "https://sourceforge.net/projects/yazi.mirror/files/${tag}/yazi-${arch}.zip/download" -o "$TMPDIR/yazi.zip"; } && \
unzip -q "$TMPDIR/yazi.zip" -d "$TMPDIR" && \
sudo install -m 0755 "$(find "$TMPDIR" -type f -name yazi -executable -print -quit)" /usr/local/bin/yazi && \
rm -rf "$TMPDIR" && yazi --version
```