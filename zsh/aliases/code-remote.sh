function coder() {
  # 检查是否提供了主机名和路径
  if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Usage: coder <host_alias> <remote_path>"
    echo "Example: coder my-server /path/to/project"
    echo ""
    echo "🚨 路径必须是完整的绝对路径"
    echo "🐛 ~ 会被解析为本地路径，如果本地用户和远端用户不一样，会造成错误"
    echo ""
    echo "✨ 推荐先 ssh 连接到服务器，进入目标目录，使用"
    echo "1️⃣ pwd : 查看目录到绝对路径"
    echo "2️⃣ realpath test.txt : 查看目录下某个文件的的绝对路径"
    echo "然后复制绝对路径，手动粘贴使用"
    return 1
  fi
  
  # 执行 VS Code 远程命令
  code --remote ssh-remote+$1 $2
  echo "🚀 Attempting to open '$2' on host '$1' in VS Code..."
}
