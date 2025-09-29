# brew
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
