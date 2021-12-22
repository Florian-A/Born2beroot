# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    monitoring.sh                                      :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: f██████ <f██████@student.42lyon.fr>        +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2021/12/14 00:20:45 by f██████           #+#    #+#              #
#    Updated: 2021/12/14 23:34:19 by f██████          ###   ########lyon.fr    #
#                                                                              #
# **************************************************************************** #

#!/bin/bash
arch=$(uname -a);

socket=$(lscpu | grep -E '^Socket\(' | rev | cut -d' ' -f1 | rev);
vcpu=$(lscpu | grep -E '^CPU\(' | rev | cut -d' ' -f1 | rev);

mem_used=$(free -m | head -n 2 | tail -1 | awk '{print $3}');
mem_total=$(free -m | head -n 2 | tail -1 | awk '{print $2}');
mem_used_percent=$(($mem_used*100/$mem_total));

sda_size=$((($(df /boot | awk 'NR > 1 {print $2}') + $(df / | awk 'NR > 1 {print $2}') + $(df /srv | awk 'NR > 1 {print $2}') + $(df /home | awk 'NR > 1 {print $2}') + $(df /tmp | awk 'NR > 1 {print $2}') + $(df /var | awk 'NR > 1 {print $2}') + $(df /var/log | awk 'NR > 1 {print $2}')) / 1024 + $(free -m | head -n 3 | tail -1 | awk '{print $2}')));
sda_used=$((($(df /boot | awk 'NR > 1 {print $3}') + $(df / | awk 'NR > 1 {print $3}') + $(df /srv | awk 'NR > 1 {print $3}') + $(df /home | awk 'NR > 1 {print $3}') + $(df /tmp | awk 'NR > 1 {print $3}') + $(df /var | awk 'NR > 1 {print $3}') + $(df /var/log | awk 'NR > 1 {print $3}')) / 1024 + $(free -m | head -n 3 | tail -1 | awk '{print $3}')));
sda_used_percent=$(($sda_used*100/$sda_size));

cpu_loaded_user=$(top -bn1 | grep '%Cpu(s)' | awk '{print $2}' | sed 's:\.[^|]*::g');
cpu_loaded_sys=$(top -bn1 | grep '%Cpu(s)' | awk '{print $4}' | sed 's:\.[^|]*::g');
cpu_loaded=$((cpu_loaded_user+cpu_loaded_sys));

last_boot=$(who -b | cut -d ' ' -f13-15);

raw_lvm=$(lsblk -f | grep "sda2_crypt" | awk '{print $3}');
is_lvm="no";
if [ $raw_lvm = "LVM2" ]
then
	is_lvm="yes";
fi

esta_connections=$(ss -s | grep "estab" | awk '{print $4}' | rev | cut -c2- | rev);
user_log=$(who | cut -d' ' -f1 | sort | uniq | wc |  awk '{print $1}');

ipv4=$(sudo ifconfig enp0s3 | grep "inet " | awk '{print $2}');
mac_address=$(sudo ifconfig enp0s3 | grep "ether " | awk '{print $2}');

raw_cmd=$(cat /var/log/sudo/sudo.log | wc | awk '{print $1}');
sudo_cmd=$(($raw_cmd / 2));

clear;
echo "-------------------------------------------------------------------------------
# Architecture: $arch
-------------------------------------------------------------------------------
# CPU physical: $socket
# vCPU: $vcpu
# CPU load: $cpu_loaded%
# Memory Usage: $mem_used MB / $mem_total MB ($mem_used_percent%)
# Disk Usage: $sda_used MB / $sda_size MB ($sda_used_percent%)
-------------------------------------------------------------------------------
# Last boot: $last_boot
# LVM use: $is_lvm
-------------------------------------------------------------------------------
# Connection(s) TCP: $esta_connections
# User(s) log: $user_log
# Network: IP $ipv4 ($mac_address)
-------------------------------------------------------------------------------
# Sudo history: $sudo_cmd
-------------------------------------------------------------------------------"| wall -n;
