#!/bin/bash

# GitHub 仓库信息(需要根据 release 页实际文件名手动构造文件名)
REPO="sxyazi/yazi"
BINARY_NAME="yazi"
upgrade=false

# 获取最新版本号
get_latest_version() {
	curl -s "https://api.github.com/repos/${REPO}/releases/latest" | grep '"tag_name":' | sed -E 's/.*"v?([0-9.]+)".*/\1/'
	# reutrn '0.54.0'
}

# 检测操作系统和架构
detect_os_and_arch() {
	local uname_output=$(uname -a)
	if [[ $uname_output == *"Linux"* ]]; then
		if [[ $uname_output == *"x86_64"* ]]; then
			echo "linux_x86_64"
		elif [[ $uname_output == *"aarch64"* || $uname_output == *"armv"* ]]; then
			echo "linux_arm"
		else
			echo "linux_unknown"
		fi
	elif [[ $uname_output == *"Darwin"* ]]; then
		echo "macos"
	else
		echo "unknown"
	fi
}

# 安装或升级软件
install_or_upgrade() {
	local os_arch=$(detect_os_and_arch)
	local latest_version=$(get_latest_version)

	if [ "$os_arch" = "macos" ]; then
		if ! command -v brew &>/dev/null; then
			echo "Homebrew 未安装，请先安装 Homebrew"
			exit 1
		fi

		if ! brew list $BINARY_NAME &>/dev/null; then
			echo "正在使用 Homebrew 安装 ${BINARY_NAME}..."
			brew install $BINARY_NAME
			# brew install yazi ffmpegthumbnailer unar jq poppler fd ripgrep fzf zoxide font-symbols-only-nerd-font
		elif $upgrade; then
			echo "正在使用 Homebrew 升级 ${BINARY_NAME}..."
			brew upgrade $BINARY_NAME
		fi
	else
		# 构造文件名(每个软件都不一样)
		# local filename="${BINARY_NAME}-${latest_version}"
		local filename="${BINARY_NAME}-"
		case $os_arch in
		linux_arm)
			filename+="aarch64-unknown-linux-gnu"
			;;
		linux_x86_64)
			filename+="x86_64-unknown-linux-gnu"
			;;
		*)
			echo "不支持的系统架构: $os_arch"
			exit 1
			;;
		esac
		filename+=".zip"

		local download_url="https://github.com/${REPO}/releases/download/v${latest_version}/${filename}"

		# 创建临时目录
		local temp_dir=$(mktemp -d)

		# 下载并解压文件
		# curl -L "$download_url" | tar -xz -C "$temp_dir"
		curl -L "$download_url" -o "$temp_dir/download.zip" && unzip "$temp_dir/download.zip" -d "$temp_dir"

		# 设置执行权限
		chmod +x "$temp_dir/$BINARY_NAME"

		# 移动二进制文件到 /usr/local/bin
		sudo mv "$temp_dir/$BINARY_NAME" "/usr/local/bin/$BINARY_NAME"

		# 清理临时目录
		rm -rf "$temp_dir"
	fi

	echo "${BINARY_NAME} 安装完成，版本为 ${latest_version}"
}

# 主函数
main() {

	if ! command -v $BINARY_NAME &>/dev/null; then
		echo "${BINARY_NAME} 未安装，正在安装..."
		install_or_upgrade
	else
		echo "${BINARY_NAME} 已安装"

		local current_version=$($BINARY_NAME --version | cut -d ' ' -f 2)
		local latest_version=$(get_latest_version)

		if [ "$current_version" != "${latest_version#}" ]; then
			echo "当前版本: $current_version"
			echo "发现新版本: $latest_version"

			if $upgrade; then
				echo "正在升级 ${BINARY_NAME}..."
				install_or_upgrade
			else
				echo "如需升级，请将 upgrade 变量设置为 true"
			fi
		else
			echo "${BINARY_NAME} 已是最新版本: ${latest_version}"
		fi
	fi
}

# 执行主函数
main
