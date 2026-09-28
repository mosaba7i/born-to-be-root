# Verification checklist (run in VM, in order)

Copy each block. Any mismatch stops the run until fixed.

## System and partitions

```bash
hostnamectl | grep malsabah42
lsb_release -a || cat /etc/debian_version
lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINT
sudo vgs; sudo lvs
df -h
! dpkg -l | grep -Ei "xorg|wayland|gnome|kde|xfce" || echo "GUI found, fail"
```

Pass: hostname `malsabah42`, Debian stable, crypt plus LVM present, no GUI packages.

## Users and groups

```bash
id malsabah
getent group user42 sudo
```

Pass: `malsabah` in both `user42` and `sudo`.

## SSH

```bash
grep -E "^Port 4242" /etc/ssh/sshd_config
grep -E "^PermitRootLogin no" /etc/ssh/sshd_config
sudo systemctl is-active ssh
sudo ss -tlnp | grep 4242
```

Pass: active, listening on 4242, root login disabled.

## Firewall

```bash
sudo ufw status numbered
sudo systemctl is-enabled ufw
```

Pass: only `4242/tcp ALLOW`, enabled.

## Password policy

```bash
grep -E "PASS_MAX_DAYS 30|PASS_MIN_DAYS 2|PASS_WARN_AGE 7" /etc/login.defs
grep -E "minlen|ucredit|lcredit|dcredit|maxrepeat|usercheck|difok" /etc/security/pwquality.conf
chage -l malsabah | head -n 10
chage -l root | head -n 10
```

Pass: ageing 30/2/7, quality rules present.

## Sudo

```bash
sudo visudo -c
sudo cat /etc/sudoers.d/b2br
ls -l /var/log/sudo/
```

Pass: parsed OK, 3 tries, custom message, log file path, requiretty, secure path.

## AppArmor

```bash
sudo aa-status | head -n 30
```

Pass: module loaded, profiles in enforce mode.

## Monitoring

```bash
ls -l /usr/local/bin/monitoring.sh
bash -n /usr/local/bin/monitoring.sh
sudo crontab -l | grep monitoring
sudo /usr/local/bin/monitoring.sh
```

Pass: executable, syntax OK, two cron lines, wall broadcast with all 11 fields and no errors.
