# Ubuntu 安装 Docker
文档: https://docs.docker.com/engine/install/ubuntu/#install-using-the-repository

## 1️⃣ 一次复制执行下面
```bash
sudo apt-get update
sudo apt-get install -y ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
```

## 2️⃣ 安装 Docker packages(默认使用最新版)
```bash
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

## 3️⃣ 将当前用户添加到 docker 组来避免使用 docker 时必须加上 sudo
```bash
sudo usermod -aG docker $USER
```

## 4️⃣ 重新加载用户组使其生效
```bash
exec zsh
```

## 5️⃣ 显示当前用户所属的所有用户组，如果没有 Docker 证明有问题
```bash
groups
```
