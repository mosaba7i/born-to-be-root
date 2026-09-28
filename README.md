*This project has been created as part of the 42 curriculum by malsabah.*

# Born to be root

My Debian server, hardened and monitored. No bonus, mandatory only, and it actually boots.

![my server](img/server.png)

## Description

Goal: build a first hardened server in VirtualBox and learn virtualization the hard way. Minimal Debian, no GUI, encrypted LVM, SSH on 4242, UFW with one open port, strict passwords, logged sudo, and a `monitoring.sh` script that spams every terminal with `wall`.

What I did, in short: created a 20 GB fixed VM named `malsabah42`, installed Debian with encrypted LVM, locked down SSH and UFW, enforced the password policy, hardened sudo, enabled AppArmor, dropped in the monitoring script on cron, shut down cleanly, and hashed the disk into `signature.txt`.

Bonus: not done. This repo is mandatory only.

## Instructions

You need VirtualBox 7, the Debian netinst ISO, 2 GB RAM and 2 vCPU for the guest.

1. Create VM `malsabah42`, 20 GB fixed VDI. NAT with host 4242 forwarded to guest 4242.
2. Install Debian: hostname `malsabah42`, user `malsabah`, only SSH server and standard utilities. No desktop.
3. Partition per the table below, then follow the SSH, UFW, password, sudo, and monitoring steps.
4. Shut down, hash the disk, paste into `signature.txt`.

```bash
# ssh into the beast
ssh -p 4242 malsabah@localhost

# copy the monitoring script in (from host)
scp -P 4242 monitoring.sh malsabah@localhost:/tmp/
sudo cp /tmp/monitoring.sh /usr/local/bin/monitoring.sh
sudo chmod +x /usr/local/bin/monitoring.sh
sudo crontab -e
# @reboot /usr/local/bin/monitoring.sh
# */10 * * * * /usr/local/bin/monitoring.sh

# signature (run on host AFTER shutdown, VM powered off, no snapshots)
sha1sum ~/VirtualBox\ VMs/malsabah42/malsabah42.vdi
```

## How I built it

### 1. VM creation

New VM, Debian 64-bit, 2048 MB RAM, 20 GB fixed disk. Fixed, not dynamic, so the hash is stable and duplication is fast.

![vm creation](img/01-vm-creation.gif)

### 2. Install and partitioning

Hostname `malsabah42`. EFI 512 MB, `/boot` 1024 MB, rest LUKS encrypted with LVM `vg0`: swap 2 GB, `/` 4 GB, `/var` 3 GB, `/var/log` 2 GB, `/home` 3 GB, `/srv` 3 GB spare, `/tmp` 1 GB, about 1.4 GB free for defense snapshots.

Why 20 GB fixed: the mandatory layout fits with room to breathe, logs cannot eat root, and the disk stays small enough to duplicate and hash quickly. 8 to 12 GB would be too tight, 40 GB would just waste host space and hashing time. OVA reference uses the same 20 GB base (link below).

![partitioning](img/02-partitioning.gif)

Software selection: only SSH server and standard utilities. If you see GNOME, you already failed.

### 3. SSH on 4242

In `/etc/ssh/sshd_config`:

```text
Port 4242
PermitRootLogin no
```

```bash
sudo systemctl restart ssh
sudo ss -tlnp | grep 4242
ssh -p 4242 malsabah@localhost whoami
```

Root over SSH is blocked, I am in on 4242.

![ssh](img/03-ssh.gif)

### 4. UFW, one port to rule them all

```bash
sudo apt install -y ufw
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow 4242/tcp
sudo ufw enable
sudo ufw status numbered
```

![ufw](img/04-ufw.png)

### 5. Users and sudo

```bash
groupadd user42 || true
usermod -aG user42,sudo malsabah
id malsabah
```

`visudo` drop-in `/etc/sudoers.d/b2br`:

```text
Defaults passwd_tries=3
Defaults badpass_message="Wrong password, incident logged."
Defaults log_input, log_output
Defaults logfile="/var/log/sudo/sudo.log"
Defaults requiretty
Defaults secure_path="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin"
```

```bash
sudo mkdir -p /var/log/sudo
sudo visudo -c
```

Type a wrong sudo password once and enjoy the custom message. Three strikes and you are out.

![sudo](img/05-sudo.png)

### 6. Password policy, aka pain

`/etc/login.defs`: `PASS_MAX_DAYS 30`, `PASS_MIN_DAYS 2`, `PASS_WARN_AGE 7`. Plus `libpam-pwquality` with min 10 chars, upper, lower, digit, max 3 repeats, no username inside, 7 chars different from old password. Then change every password including root.

```bash
chage -l malsabah
```

![password policy](img/06-password.png)

### 7. Monitoring script

Needs no arguments, prints 11 lines, never errors. Cron runs it at boot and every 10 minutes, output piped to `wall`.

```bash
#!/bin/bash
set -u
arch=$(uname -a 2>/dev/null || echo unknown)
pcpu=$(grep -c "^physical id" /proc/cpuinfo 2>/dev/null || echo 0)
vcpu=$(grep -c "^processor" /proc/cpuinfo 2>/dev/null || echo 0)
mem_total=$(free -m 2>/dev/null | awk '/^Mem:/ {print $2}'); mem_used=$(free -m 2>/dev/null | awk '/^Mem:/ {print $3}')
mem_perc=$(free 2>/dev/null | awk '/^Mem:/ {printf "%.2f", $3/$2*100}'); [ -z "${mem_total:-}" ] && { mem_total=0; mem_used=0; mem_perc=0.00; }
disk_total=$(df -Bg --total 2>/dev/null | awk '/^total/ {print $2}' | tr -d 'G'); disk_used=$(df -Bm --total 2>/dev/null | awk '/^total/ {print $3}')
disk_perc=$(df --total 2>/dev/null | awk '/^total/ {print $5}' | tr -d '%'); [ -z "${disk_total:-}" ] && { disk_total=0; disk_used=0; disk_perc=0; }
cpu_load=$(top -bn1 2>/dev/null | awk -F',' '/Cpu\(s\)/ {gsub(/[^0-9.]/,"",$4); print 100-$4}' | head -1); [ -z "${cpu_load:-}" ] && cpu_load=0
last_boot=$(who -b 2>/dev/null | awk '{print $3, $4}'); [ -z "${last_boot:-}" ] && last_boot="unknown"
lvm_use="no"; lsblk 2>/dev/null | grep -q "lvm" && lvm_use="yes"
tcp_conn=$(ss -t state established 2>/dev/null | tail -n +2 | wc -l | tr -d ' '); user_log=$(who 2>/dev/null | wc -l | tr -d ' ')
ip_addr=$(hostname -I 2>/dev/null | awk '{print $1}'); [ -z "${ip_addr:-}" ] && ip_addr="unknown"
mac_addr=$(ip link 2>/dev/null | awk '/ether/ {print $2; exit}'); [ -z "${mac_addr:-}" ] && mac_addr="unknown"
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
```

![monitoring wall](img/07-monitoring.gif)

Stop it without touching the file (defense trick): `sudo pkill -f monitoring.sh`.

### 8. Signature, the final boss

Shut down, no snapshots, hash the disk:

```bash
sudo shutdown now
sha1sum ~/VirtualBox\ VMs/malsabah42/malsabah42.vdi
```

Paste the hash into `signature.txt`. Boot the VM again and the hash changes, so duplicate the disk or snapshot per evaluation.

![signature](img/08-signature.png)

## Project description

OS choice: Debian stable. Small installer, simple text setup, AppArmor on by default, huge peer knowledge base. Rocky is great for RHEL shops with SELinux and firewalld, but heavier to install and debug for a first server. I picked the boring option that lets me focus on the subject rules.

Design choices: LVM on LUKS with separate `/var/log` so logs never kill root, SSH root login off, UFW default deny with only 4242 open, ageing 30/2/7 plus pwquality, sudo fully logged to `/var/log/sudo/`, AppArmor enforcing, only ssh plus ufw plus cron running.

Debian vs Rocky: apt and DEB versus dnf and RPM. Debian boots faster minimal, Rocky enforces SELinux out of the box.

AppArmor vs SELinux: AppArmor confines by path (`aa-status`), simple. SELinux labels everything with contexts (`sestatus`), finer but blocks custom SSH ports and web roots unless you relabel.

UFW vs firewalld: UFW is one zone and dead simple (`ufw allow 4242/tcp`). firewalld adds zones and runtime versus permanent rules. Same result here: one open port.

VirtualBox vs UTM: VirtualBox holds `.vdi` under `~/VirtualBox VMs/`, hash with `sha1sum`. UTM holds `.qcow2` in its container, hash with `shasum`. Same rules: fixed disk, no snapshots at evaluation start.

## Resources

* Subject `b2br.pdf` v5.2, 18 pages, local copy was in `~/Downloads/b2br.pdf`.
* Debian install manual: https://www.debian.org/releases/stable/installmanual
* Debian wiki encrypted LVM, `man cryptsetup`, `man lvm`.
* AppArmor: https://wiki.debian.org/AppArmor.
* UFW: https://wiki.ubuntu.com/UncomplicatedFirewall.
* `man sshd_config`, `man sudoers`, `man crontab`, `man wall`.
* OVA reference: https://drive.google.com/file/d/15najeg0HZuJo8OQYMoMlu5zakKXUsrdZ/view?usp=sharing
* Style inspiration: https://github.com/chlimous/42-born2beroot_guide
* AI use: AI drafted the README outline and the monitoring script template from the subject. I checked every command against Debian stable manuals. No passwords, keys, or signatures were generated by AI.

## Screenshots

All in `img/`. Files ending in `.gif` are screen recordings, `.png` are stills. If an image is missing, I have not captured it yet. Target list: `01-vm-creation.gif`, `02-partitioning.gif`, `03-ssh.gif`, `04-ufw.png`, `05-sudo.png`, `06-password.png`, `07-monitoring.gif`, `08-signature.png`, `server.png`.
