# ---- auto proxy ----
pxyon > /dev/null

# pnpm
export PNPM_HOME="/Users/tony/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end


# ---- bili translate ----
# 上传当前视频到指定目录
# 使用方法: up IntroducingAIExtensionsBeta.mp4
up() {
  rsync -avP "$1" 4090x8:~/VideoSubAI/demo
}

# 从指定目录现下载压制好的视频
# 使用方法: down IntroducingAIExtensionsBeta_subed.mp4
down() {
  rsync -avP 4090x8:~/VideoSubAI/demo/"$1" .
}

