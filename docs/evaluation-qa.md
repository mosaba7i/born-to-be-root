# Evaluation Q and A

Short answers I give at defense. Each maps to a live command.

## OS and packages

Q: Why Debian over Rocky?
A: First server, smaller installer, AppArmor simpler than SELinux for this scope, large peer docs. Rocky fits RHEL production but needs more SELinux and firewalld tuning.

Q: aptitude vs apt?
A: Both frontends to dpkg. `apt` is the modern CLI for interactive use. `aptitude` adds an interactive resolver. I used `apt` for install and upgrade.

Q: What is AppArmor?
A: Path based mandatory access control. Profiles per program in `/etc/apparmor.d`, enforce or complain mode. Check with `aa-status`. Mine is enforcing at boot.

Q: What is SELinux?
A: Label based mandatory access control used by Rocky. Contexts on files and processes, type enforcement. Stronger granularity, harder to debug. Not used here because OS is Debian.

## Disk and LVM

Q: Show encrypted partitions.
A: Run `lsblk`, `sudo lvs`, `cryptsetup status`. At least 2 LVs sit on LUKS. Mine has 7 LVs on one LUKS PV.

Q: Why separate /var/log?
A: Logs cannot fill root, sudo logs stay isolated, easier quota and backup.

Q: Why fixed 20 GB?
A: Fits mandatory plus bonus WordPress with reserve, deterministic signature, fast duplication and hashing. See `docs/partitioning-20gb.md`.

## Network and security

Q: Show SSH port and root block.
A: `grep Port /etc/ssh/sshd_config`, `ss -tlnp | grep 4242`, then `ssh -p 4242 root@localhost` fails while `ssh -p 4242 malsabah@localhost` works.

Q: Show firewall.
A: `sudo ufw status numbered`. Only 4242 open, default deny incoming, enabled at boot.

Q: UFW vs firewalld?
A: UFW is a simple iptables frontend for one zone VMs. firewalld adds zones and runtime versus permanent rules. Same result here: one open port.

Q: Create a new user and assign a group.
A: `sudo adduser evaluser`, `sudo usermod -aG user42 evaluser`, `id evaluser`.

## Password and sudo

Q: Show password policy.
A: `chage -l malsabah`, `/etc/login.defs`, `/etc/security/pwquality.conf`. Expiry 30 days, min 2 days, warn 7 days, 10 chars with classes, max 3 repeats, username check, difok 7.

Q: Show sudo rules.
A: `sudo cat /etc/sudoers.d/b2br`, `sudo visudo -c`, `ls /var/log/sudo/`. Three tries, custom message, input and output logging, requiretty, restricted path.

## Monitoring

Q: Explain monitoring.sh.
A: Reads uname, proc, free, df, top, who, ss, ip, journalctl, pipes to wall. Fallbacks avoid errors. Cron runs it at reboot and every 10 minutes.

Q: Stop it without modifying.
A: `sudo pkill -f monitoring.sh` for the running instance, or `sudo crontab -e` to comment lines for persistence demo, then re-enable.

## Virtualization

Q: VirtualBox vs UTM?
A: VirtualBox stores `.vdi` under `~/VirtualBox VMs/`, sha1 with `sha1sum`. UTM stores `.qcow2` under the UTM container, sha1 with `shasum`. Same subject rules apply.

Q: Show signature.
A: `cat signature.txt` in repo matches host `sha1sum` of the powered off disk. No snapshots at start.
