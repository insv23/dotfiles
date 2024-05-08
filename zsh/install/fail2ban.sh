#!/bin/bash

if command -v fail2ban-client &> /dev/null; then
  echo "fail2ban 已安装"
else
  echo "fail2ban 未安装"
  if uname -a | grep -q "Ubuntu"; then 
    # Install fail2ban
    sudo apt update && sudo apt upgrade
    sudo apt install fail2ban -y

    # Copy the default configuration file to /etc/fail2ban/jail.local
    sudo cp /etc/fail2ban/jail.{conf,local}

    # Start fail2ban service
    sudo systemctl start fail2ban

    # Enable fail2ban service to start on boot
    sudo systemctl enable fail2ban

    # Check if fail2ban is enabled to start on boot
    sudo systemctl is-enabled fail2ban

    # Check the status of fail2ban
    sudo systemctl status fail2ban
  fi
fi
