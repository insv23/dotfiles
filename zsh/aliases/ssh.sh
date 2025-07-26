#!/bin/bash

# kls - 以树形结构展示 SSH 配置
kls() {
    local ssh_config="${HOME}/.ssh/config"
    
    # 如果传入参数，使用指定的配置文件
    if [[ -n "$1" ]]; then
        ssh_config="$1"
    fi
    
    # 检查配置文件是否存在
    if [[ ! -f "$ssh_config" ]]; then
        echo "❌ SSH config file not found: $ssh_config"
        return 1
    fi
    
    # 颜色定义
    local CYAN='\033[36m'
    local YELLOW='\033[33m'
    local GREEN='\033[32m'
    local RED='\033[31m'
    local BLUE='\033[34m'
    local MAGENTA='\033[35m'
    local BOLD='\033[1m'
    local RESET='\033[0m'
    local DIM='\033[2m'
    
    # 统计变量
    local total_hosts=0
    local hosts_with_key=0
    
    # 打印标题
    echo -e "\n${BOLD}${CYAN}SSH Hosts${RESET}"
    
    # 临时文件存储解析结果
    local temp_file=$(mktemp)
    
    # 解析 SSH 配置文件
    local current_host=""
    local hostname=""
    local user=""
    local port=""
    local has_identity=""
    local host_count=0
    
    while IFS= read -r line; do
        # 去除前后空格
        line=$(echo "$line" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
        
        # 跳过空行和注释
        [[ -z "$line" || "$line" =~ ^# ]] && continue
        
        # 检测 Host 块的开始
        if [[ "$line" =~ ^Host[[:space:]]+ ]]; then
            # 如果已经在处理一个 Host 块，先保存它
            if [[ -n "$current_host" ]]; then
                echo "$current_host|$hostname|$user|$port|$has_identity" >> "$temp_file"
                ((total_hosts++))
                [[ "$has_identity" == "yes" ]] && ((hosts_with_key++))
            fi
            
            # 重置变量
            current_host=$(echo "$line" | sed 's/^Host[[:space:]]*//')
            hostname=""
            user=""
            port=""
            has_identity="no"
            ((host_count++))
            
        elif [[ -n "$current_host" ]]; then
            # 解析 Host 块内的配置
            if [[ "$line" =~ ^HostName[[:space:]]+ ]]; then
                hostname=$(echo "$line" | sed 's/^HostName[[:space:]]*//')
            elif [[ "$line" =~ ^User[[:space:]]+ ]]; then
                user=$(echo "$line" | sed 's/^User[[:space:]]*//')
            elif [[ "$line" =~ ^Port[[:space:]]+ ]]; then
                port=$(echo "$line" | sed 's/^Port[[:space:]]*//')
            elif [[ "$line" =~ ^IdentityFile[[:space:]]+ ]]; then
                has_identity="yes"
            fi
        fi
    done < "$ssh_config"
    
    # 保存最后一个 Host 块
    if [[ -n "$current_host" ]]; then
        echo "$current_host|$hostname|$user|$port|$has_identity" >> "$temp_file"
        ((total_hosts++))
        [[ "$has_identity" == "yes" ]] && ((hosts_with_key++))
    fi
    
    # 读取并显示结果
    local line_count=0
    local total_lines=$(wc -l < "$temp_file" | tr -d ' ')
    
    while IFS='|' read -r host hostname user port identity; do
        ((line_count++))
        
        # 判断是否是最后一个
        local tree_prefix="├──"
        local sub_prefix="│   "
        if [[ $line_count -eq $total_lines ]]; then
            tree_prefix="└──"
            sub_prefix="    "
        fi
        
        # 打印主机名
        echo -e "${tree_prefix} ${YELLOW}${host}${RESET}"
        
        # 打印主机地址
        if [[ -n "$hostname" ]]; then
            echo -e "${sub_prefix}├── ${DIM}Host:${RESET} ${BLUE}${hostname}${RESET}"
        fi
        
        # 打印端口（如果非标准）
        if [[ -n "$port" && "$port" != "22" ]]; then
            echo -e "${sub_prefix}├── ${DIM}Port:${RESET} ${CYAN}${port}${RESET}"
        fi
        
        # 打印用户
        if [[ -n "$user" ]]; then
            echo -e "${sub_prefix}├── ${DIM}User:${RESET} ${MAGENTA}${user}${RESET}"
        else
            echo -e "${sub_prefix}├── ${DIM}User:${RESET} ${DIM}(default)${RESET}"
        fi
        
        # 打印密钥状态
        if [[ "$identity" == "yes" ]]; then
            echo -e "${sub_prefix}└── ${DIM}Key:${RESET} ${GREEN}✓${RESET}"
        else
            echo -e "${sub_prefix}└── ${DIM}Key:${RESET} ${RED}✗${RESET}"
        fi
        
    done < "$temp_file"
    
    # 清理临时文件
    rm -f "$temp_file"
    
    # 打印统计信息
    echo -e "\n${DIM}Summary: ${total_hosts} hosts (${hosts_with_key} with keys, $((total_hosts - hosts_with_key)) without)${RESET}\n"
}

# 创建 ssh 密钥(默认无密码)
ssh-ck () {
	if [ -z "$1" ]
	then
		echo "用法："
		echo "  ssh-ck server_<服务器名称>@<服务器用户>   # 生成连接到特定服务器的密钥"
		echo "  ssh-ck github_<GitHub账户>             # 生成连接到GitHub账户的密钥"
		return 1
	fi
	user_host=$(whoami)@$(hostname)
	key_name="$HOME/.ssh/$1"
	ssh-keygen -f "$key_name" -t rsa -N '' -C "$user_host to $1"

	# 使用 pbcopy 复制公钥到剪贴板 (仅限 macOS)
	if [[ "$OSTYPE" == "darwin"* ]]; then
		pbcopy < "$key_name.pub"
		echo "公钥已复制到剪贴板。"
	elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
		# Linux 下尝试使用 xclip 或 xsel (需要安装)
		if command -v xclip >/dev/null 2>&1; then
			xclip -selection clipboard < "$key_name.pub"
			echo "公钥已复制到剪贴板 (使用 xclip)。"
		elif command -v xsel >/dev/null 2>&1; then
			xsel --clipboard --input < "$key_name.pub"
			echo "公钥已复制到剪贴板 (使用 xsel)。"
		else
			echo "无法复制公钥到剪贴板。请手动复制 $key_name.pub 的内容。"
		fi
	else
		echo "无法复制公钥到剪贴板。请手动复制 $key_name.pub 的内容。"
	fi
}


# kitty `kitten ssh`
## 目前我体会到的唯一优势是: 新建 Kitty window, 会是服务器的；普通 ssh 是本地的终端
## 但没有断开自动重连能力，所以还是更倾向使用下面的 autossh
# 自动重连只是重连上了，并没有恢复原有的服务，所以还是需要使用 `zja 名称` 恢复
# 意外发现 kitten ssh 能记住密码(虽然不知道多久)，但 4090 和 macmini 两个连接都无需再输入密码
# 现在的工作流是:
# 1. 使用 `k 主机名` 登录。有 key 的自动登录，没有 key 的输入密码
# 2. 需要持久的任务 + 连接易断开的任务，使用 zja 创建/重新进入到持久会话
# 3. 意外断开后，使用 上方向键 输入上一条 `k 主机名` 命令再次登录
alias k="kitten ssh"


# SSH connect: try key first, then password from env var
# function a() {
#   local host="$1"
#   local password_var="SSH_PW_${host}"
#   local password
#   local hostname
#   local port

#   if [ -z "$host" ]; then
#     echo "用法: a 主机"
#     echo "主机需要在 ~/.ssh/config 中配置"
#     echo "根据主机 config 中是否有 IdentityFile 来判断是用密钥还是密码登录，如有则使用密钥登录，否则使用密码登录"
#     return 1
#   fi

#   # 检查主机是否在 ssh config 中配置，并且获取该主机的配置块
#   local host_config
#   host_config=$(awk "/^Host[[:space:]]+${host}\$/{p=1;print;next} p&&/^Host[[:space:]]+/{p=0;exit} p{print}" ~/.ssh/config)
  
#   if [ -z "$host_config" ]; then
#     echo "错误：主机 $host 未在 ~/.ssh/config 中配置"
#     echo "请先在 ~/.ssh/config 中添加配置"
#     return 1
#   fi

#   # 从配置块中提取 HostName 和 Port
#   hostname=$(echo "$host_config" | awk '/^[[:space:]]*HostName[[:space:]]+/ {print $2}')
#   port=$(echo "$host_config" | awk '/^[[:space:]]*Port[[:space:]]+/ {print $2}')
  
#   if [ -z "$hostname" ]; then
#     echo "错误：无法从配置中获取 HostName"
#     return 1
#   fi

#   # 检查是否是首次连接
#   local known_host_pattern
#   if [ -n "$port" ] && [ "$port" != "22" ]; then
#     known_host_pattern="[$hostname]:$port"
#   else
#     known_host_pattern="$hostname"
#   fi

#   if ! ssh-keygen -F "$known_host_pattern" >/dev/null 2>&1; then
#     echo "注意: 在新设备第一次连接时不能用，需要先用 ssh 连接上一次后才能用"
#     echo "请先使用: ssh $host"
#     return 1
#   fi

#   # 检查特定主机的配置块中是否有 IdentityFile
#   if echo "$host_config" | grep -q "^[[:space:]]*IdentityFile"; then
#     # 有 IdentityFile，使用 autossh 登录
#     autossh -M 0 \
#       -o "ServerAliveInterval 30" \
#       -o "ServerAliveCountMax 3" \
#       -o "BatchMode=yes" \
#       "$host"
#     return $?
#   fi

#   # 没有 IdentityFile，使用密码登录
#   typeset -A var_map
#   var_map[$password_var]="${(P)password_var}"
#   password=${var_map[$password_var]}

#   if [ -z "$password" ]; then
#     echo "未找到 ${password_var} 环境变量。"
#     echo -n "请输入 ${host} 的密码: "
#     read input_password
#     echo  # 换行
    
#     if [ -z "$input_password" ]; then
#       echo "错误：密码不能为空"
#       return 1
#     fi
    
#     # 将密码保存到环境变量中，存储在 ~/.envrc 中
#     echo "export ${password_var}=\"${input_password}\"" >> ~/.envrc && cd ~ && direnv allow
    
#     # 更新当前环境变量，这样就不用退出重进
#     export "${password_var}=${input_password}"
    
#     # 尝试密码连接
#     sshpass -p "$input_password" ssh "$host"
#     return $?
#   fi

#   # 使用已存在的密码连接
#   sshpass -p "$password" ssh "$host"
# }