# How I did it: full solution walkthrough

Login: `malsabah`, hostname: `malsabah42`, OS: Debian 12 stable, disk: 20 GB fixed VDI, hypervisor: VirtualBox (UTM notes inline).

This is the exact order I followed. Every command below was run inside the VM unless marked as host.

## 1. VM creation on host

1. VirtualBox, New, name `malsabah42`, type Linux, version Debian 64-bit.
2. Memory 2048 MB, 2 CPU, 20 GB fixed VDI in `~/VirtualBox VMs/malsabah42/`.
3. Network: NAT with port forwarding host 4242 to guest 4242. This lets `ssh -p 4242 malsabah@localhost` work from host.
4. Attach Debian netinst ISO, boot.

Screenshot: `docs/screenshots/01-vm-settings.png` (system, storage, network tabs).

UTM difference: create Debian VM, 20 GB NVMe drive, bridged or shared network, note `.qcow2` path for signature.

## 2. Debian install

1. Choose Graphical or text install, language and timezone per campus.
2. Hostname: `malsabah42`. Domain: empty.
3. Root password: strong one meeting policy (10 chars, upper, lower, digit). Save in password manager, never in git.
4. Create user `malsabah` with strong password.
5. Partitioning: choose Manual. Steps:
   a. Create 512 MB EFI partition, FAT32, boot flag.
   b. Create 1024 MB `/boot`, ext4, unencrypted.
   c. Create rest as physical volume for encryption, set encryption passphrase.
   d. Configure encrypted volume as LVM physical volume.
   e. Create volume group `vg0`.
   f. Create logical volumes per `docs/partitioning-20gb.md`: swap 2 GB, root 4 GB, var 3 GB, var-log 2 GB, home 3 GB, srv 3 GB, tmp 1 GB.
   g. Set filesystems ext4 (swap for swap), mount points `/`, `/var`, `/var/log`, `/home`, `/srv`, `/tmp`.
   h. Finish and write to disk.
6. Software selection: check only SSH server and standard system utilities. Uncheck desktop environment, GNOME, Xfce, print server.
7. Install GRUB to primary disk, reboot, remove ISO.

Screenshots: `02-partition-table.png`, `03-lvm-layout.png`, `04-software-selection.png`.

Verify after first boot:

```bash
lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINT
sudo vgs && sudo lvs
cryptsetup status /dev/mapper/sda3_crypt
df -h
```

Expected: one `crypt` device, `vg0` with 7 LVs, `df` total near 19 GB usable.

## 3. Base packages and user setup

```bash
su -
apt update && apt upgrade -y
apt install -y sudo ufw apparmor apparmor-utils libpam-pwquality cron wall sysstat net-tools iproute2 openssh-server
groupadd user42 || true
usermod -aG user42,sudo malsabah
id malsabah
# expected: uid=1000(malsabah) gid=1000(malsabah) groups=1000(malsabah),27(sudo),1001(user42)
exit
```

Screenshot: `05-id-malsabah.png`.

## 4. SSH on port 4242

Edit `/etc/ssh/sshd_config`:

```text
Port 4242
PermitRootLogin no
PasswordAuthentication yes
```

Apply:

```bash
sudo systemctl restart ssh
sudo systemctl enable ssh
sudo ss -tlnp | grep 4242
# expected: LISTEN 0.0.0.0:4242
ssh -p 4242 malsabah@localhost whoami
# expected: malsabah
sudo ssh -p 4242 root@localhost || echo "root blocked, good"
```

Screenshot: `06-ssh-4242.png`.

Why it works: SSH daemon binds 4242, UFW later allows it, root login disabled at daemon level so password is never accepted for root.

## 5. UFW firewall

```bash
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow 4242/tcp
sudo ufw enable
sudo ufw status numbered
sudo systemctl enable ufw
```

Expected status:

```text
[ 1] 4242/tcp ALLOW IN Anywhere
```

Screenshot: `07-ufw-status.png`.

## 6. Password policy

In `/etc/login.defs`:

```text
PASS_MAX_DAYS 30
PASS_MIN_DAYS 2
PASS_WARN_AGE 7
```

In `/etc/security/pwquality.conf`:

```text
minlen = 10
ucredit = -1
lcredit = -1
dcredit = -1
maxrepeat = 3
usercheck = 1
difok = 7
enforce_for_root
```

Then rotate all passwords:

```bash
sudo passwd root
sudo passwd malsabah
chage -l malsabah
chage -l root
# expected: Maximum number of days: 30, Minimum: 2, Warning: 7
```

Test weak password fails:

```bash
sudo adduser testweak
# try password "password" or "malsabah123", it must be rejected
sudo deluser --remove-home testweak
```

Screenshot: `08-chage-policy.png`.

## 7. Sudo hardening

Create `/etc/sudoers.d/b2br` with `visudo`:

```text
Defaults passwd_tries=3
Defaults badpass_message="Access denied: incident logged."
Defaults log_input, log_output
Defaults logfile="/var/log/sudo/sudo.log"
Defaults requiretty
Defaults secure_path="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin"
```

Apply:

```bash
sudo mkdir -p /var/log/sudo
sudo visudo -c
# expected: parsed OK
sudo -k
sudo whoami
# type wrong password once, expect custom message
sudo ls /var/log/sudo/
# expected: sudo.log plus session folders
```

Screenshot: `09-sudo-log.png`.

## 8. AppArmor check

```bash
sudo systemctl enable --now apparmor
aa-status
# expected: apparmor module is loaded, profiles in enforce mode
```

Screenshot: `10-apparmor-status.png`.

## 9. Monitoring script install

From repo on host, copy into VM with scp (port 4242):

```bash
# on host:
scp -P 4242 monitoring.sh malsabah@localhost:/tmp/
# in VM:
sudo cp /tmp/monitoring.sh /usr/local/bin/monitoring.sh
sudo chmod +x /usr/local/bin/monitoring.sh
bash -n /usr/local/bin/monitoring.sh
sudo /usr/local/bin/monitoring.sh
# expect wall broadcast on all terminals
```

Cron as root (`sudo crontab -e`):

```text
@reboot /usr/local/bin/monitoring.sh
*/10 * * * * /usr/local/bin/monitoring.sh
```

Verify:

```bash
sudo crontab -l
ps aux | grep monitoring || true
sleep 600 && tty && echo "wait for wall message"
```

Stop without modifying (for defense demo):

```bash
sudo pkill -f monitoring.sh || true
```

Screenshot: `11-wall-broadcast.png`.

Sample broadcast:

```text
#Architecture: Linux malsabah42 6.1.0-amd64 #1 SMP Debian x86_64 GNU/Linux
#Physical CPU: 1
#vCPU: 2
#Memory Usage: 180/1976MB (9.10%)
#Disk Usage: 4200/19000Mb (22%)
#CPU load: 4.2%
#Last boot: 2026-09-28 19:00
#LVM use: yes
#TCP Connections: 1 ESTABLISHED
#User log: 1
#Network: IP 10.0.2.15 (08:00:27:xx:xx:xx)
#Sudo: 12 cmd
```

## 10. Final checks before signature

Run `docs/verification.md` top to bottom. Fix anything red. Then shut down:

```bash
sudo shutdown now
```

On host, capture signature, paste into `signature.txt`, commit only that file plus docs. Keep VM powered off until evaluation. No snapshots present at start.
