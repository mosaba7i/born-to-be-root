# Security policy steps (Debian)

## Hostname and users

```bash
hostnamectl set-hostname malsabah42
adduser malsabah
groupadd user42 || true
usermod -aG user42,sudo malsabah
id malsabah
```

## SSH on 4242, no root

In `/etc/ssh/sshd_config`:

```text
Port 4242
PermitRootLogin no
PasswordAuthentication yes
```

Then:

```bash
sudo systemctl restart ssh
sudo ss -tlnp | grep 4242
```

Test from host with port forwarding guest 4242 to host 4242, then `ssh -p 4242 malsabah@localhost`. Root login must fail.

## UFW, only 4242 open

```bash
sudo apt install -y ufw
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow 4242/tcp
sudo ufw enable
sudo ufw status numbered
sudo systemctl enable ufw
```

## Password policy

In `/etc/login.defs`:

```text
PASS_MAX_DAYS 30
PASS_MIN_DAYS 2
PASS_WARN_AGE 7
```

Install quality check:

```bash
sudo apt install -y libpam-pwquality
```

In `/etc/security/pwquality.conf` or `/etc/pam.d/common-password`:

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

Then change all passwords including root:

```bash
sudo passwd root
sudo passwd malsabah
chage -l malsabah
```

## Sudo hardening

File `/etc/sudoers.d/b2br` via `visudo`:

```text
Defaults passwd_tries=3
Defaults badpass_message="Access denied: incident logged."
Defaults log_input, log_output
Defaults logfile="/var/log/sudo/sudo.log"
Defaults requiretty
Defaults secure_path="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin"
```

Then:

```bash
sudo mkdir -p /var/log/sudo
sudo visudo -c
sudo -k
sudo whoami
```

Wrong password must show the custom message and allow only 3 tries. Actions appear under `/var/log/sudo/`.

## AppArmor

```bash
sudo apt install -y apparmor apparmor-utils
sudo systemctl enable --now apparmor
aa-status
```

Must show loaded profiles and enforce mode at boot.

## Cron for monitoring

Root crontab:

```text
@reboot /usr/local/bin/monitoring.sh
*/10 * * * * /usr/local/bin/monitoring.sh
```

Stop without modifying during defense: `sudo pkill -f monitoring.sh` or comment cron lines and kill running wall broadcast, then re-enable after.
