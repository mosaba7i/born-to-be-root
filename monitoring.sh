#!/bin/bash
# monitoring.sh for Born2beRoot, user malsabah
# Broadcasts system info with wall at boot and every 10 minutes via cron.
# No errors should be displayed: missing values fall back to 0 or unknown.

set -u

arch=$(uname -a 2>/dev/null || echo unknown)
pcpu=$(grep -c "^physical id" /proc/cpuinfo 2>/dev/null || echo 0)
vcpu=$(grep -c "^processor" /proc/cpuinfo 2>/dev/null || echo 0)

mem_total=$(free -m 2>/dev/null | awk '/^Mem:/ {print $2}')
mem_used=$(free -m 2>/dev/null | awk '/^Mem:/ {print $3}')
mem_perc=$(free 2>/dev/null | awk '/^Mem:/ {printf "%.2f", $3/$2*100}')
[ -z "${mem_total:-}" ] && { mem_total=0; mem_used=0; mem_perc=0.00; }

disk_total=$(df -Bg --total 2>/dev/null | awk '/^total/ {print $2}' | tr -d 'G')
disk_used=$(df -Bm --total 2>/dev/null | awk '/^total/ {print $3}')
disk_perc=$(df --total 2>/dev/null | awk '/^total/ {print $5}' | tr -d '%')
[ -z "${disk_total:-}" ] && { disk_total=0; disk_used=0; disk_perc=0; }

cpu_load=$(top -bn1 2>/dev/null | awk -F',' '/Cpu\(s\)/ {gsub(/[^0-9.]/,"",$4); print 100-$4}' | head -1)
[ -z "${cpu_load:-}" ] && cpu_load=0

last_boot=$(who -b 2>/dev/null | awk '{print $3, $4}')
[ -z "${last_boot:-}" ] && last_boot="unknown"

lvm_use="no"
lsblk 2>/dev/null | grep -q "lvm" && lvm_use="yes"

tcp_conn=$(ss -t state established 2>/dev/null | tail -n +2 | wc -l | tr -d ' ')
user_log=$(who 2>/dev/null | wc -l | tr -d ' ')

ip_addr=$(hostname -I 2>/dev/null | awk '{print $1}')
[ -z "${ip_addr:-}" ] && ip_addr="unknown"
mac_addr=$(ip link 2>/dev/null | awk '/ether/ {print $2; exit}')
[ -z "${mac_addr:-}" ] && mac_addr="unknown"

sudo_cmd=$(journalctl _COMM=sudo 2>/dev/null | grep -c COMMAND || echo 0)

msg="#Architecture: $arch
#Physical CPU: $pcpu
#vCPU: $vcpu
#Memory Usage: $mem_used/${mem_total}MB (${mem_perc}%)
#Disk Usage: $disk_used/${disk_total}Gb (${disk_perc}%)
#CPU load: $cpu_load%
#Last boot: $last_boot
#LVM use: $lvm_use
#TCP Connections: $tcp_conn ESTABLISHED
#User log: $user_log
#Network: IP $ip_addr ($mac_addr)
#Sudo: $sudo_cmd cmd"

echo "$msg" | wall 2>/dev/null || true
