#!/bin/bash

# 命令：检查命令是否存在，如果需要则安装
安装_如果_缺失() {
  if ! command -v "$1" &>/dev/null; then
    sudo apt update && sudo apt install "$1" -y < "/dev/null"
  fi
}

# 命令：下载并解压二进制文件
下载_二进制文件() {
  BIN_DIR="${HOME}/avail-light"
  mkdir -p "${BIN_DIR}"
  cd "${BIN_DIR}"

  RELEASE_URL="https://github.com/availproject/avail-light/releases/download/v1.7.5"
  wget "${RELEASE_URL}/avail-light-linux-amd64.tar.gz"
  tar -xvzf avail-light-linux-amd64.tar.gz
  cp avail-light-linux-amd64 avail-light
}

# 命令：创建并启用 systemd 服务
设置_systemd服务() {
  SERVICE_FILE="/etc/systemd/system/availd.service"
  tee "${SERVICE_FILE}" > /dev/null << EOF
[Unit]
Description=Avail Light 客户端
After=network.target
StartLimitIntervalSec=0

[Service]
User=root
ExecStart=${BIN_DIR}/avail-light --network goldberg
Restart=always
RestartSec=120

[Install]
WantedBy=multi-user.target
EOF

  sudo systemctl daemon-reload
  sudo systemctl enable availd
  sudo systemctl start availd.service
}

# 主脚本

# 如果不存在，安装 curl
安装_如果_缺失 curl

# 升级并安装必要的软件包
sudo apt update
sudo apt install make clang pkg-config libssl-dev build-essential -y

# 下载并运行二进制文件
下载_二进制文件

# 创建并启用 systemd 服务
设置_systemd服务

# 完成消息
echo '====================================== 安装完成 ========================================='
echo -e "\e[1;32m 检查状态: \e[0m\e[1;36m${CYAN} systemctl status availd.service ${NC}\e[0m"
echo -e "\e[1;32m 检查日志  : \e[0m\e[1;36m${CYAN} journalctl -f -u availd ${NC}\e[0m"
