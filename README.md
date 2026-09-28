*This project has been created as part of the 42 curriculum by malsabah.*

# Born to be root

Virtualized Debian server with hardened partitioning, security policy, and monitoring. Built from subject `b2br.pdf` version 5.2.

## Description

Goal: create a first virtual machine in VirtualBox (or UTM where VirtualBox is unavailable) and configure a minimal, hardened server without any graphical interface.

Scope of the mandatory part:

* Debian stable (or Rocky stable) with no X.org, Wayland, or equivalent graphics server.
* At least 2 encrypted partitions using LVM.
* SSH on port 4242, root login over SSH disabled.
* UFW (Debian) or firewalld (Rocky) with only port 4242 open, active at boot.
* Hostname `<login>42`, here `malsabah42`.
* Strong password policy (30 day expiry, 2 day minimum, 7 day warning, 10 chars with upper, lower, digit, max 3 identical consecutive chars, no username inside, 7 chars different from previous password except for root).
* Sudo hardened: 3 attempts, custom badpass message, logging to `/var/log/sudo/`, TTY required, restricted secure path.
* One `monitoring.sh` bash script, broadcast with `wall` at boot and every 10 minutes via cron.
* Submission is `signature.txt` (sha1 of `.vdi` or `.qcow2`) plus this README. The VM image itself is never committed.

## Instructions

### Requirements

* VirtualBox 7 or UTM, 20 GB fixed virtual disk (see `docs/partitioning-20gb.md`).
* Debian netinst ISO, latest stable.
* Host with at least 2 GB RAM and 2 vCPU assigned to the VM.

### Installation

1. Create a VM named `malsabah42`, type Linux Debian 64-bit, 2048 MB RAM, 20 GB fixed VDI.
2. Boot the Debian netinst ISO, choose text install, hostname `malsabah42`.
3. Partition manually with LVM and encryption (see `docs/partitioning-20gb.md`).
4. Install only SSH server and standard utilities. Do not install any desktop environment.
5. Boot, log in as root, create user `malsabah`, add to `user42` and `sudo` groups.
6. Apply `docs/security-policy.md` (SSH, UFW, password policy, sudo).
7. Copy `monitoring.sh` to `/usr/local/bin/`, set executable, register in root crontab.
8. Generate `signature.txt` (see below), shut down cleanly before evaluation.

### Monitoring script

```bash
sudo cp monitoring.sh /usr/local/bin/monitoring.sh
sudo chmod +x /usr/local/bin/monitoring.sh
sudo crontab -e
# add:
# @reboot /usr/local/bin/monitoring.sh
# */10 * * * * /usr/local/bin/monitoring.sh
```

### Signature

```bash
# Linux / VirtualBox:
sha1sum ~/VirtualBox\ VMs/malsabah42/malsabah42.vdi > signature.txt
# macOS VirtualBox:
shasum ~/VirtualBox\ VMs/malsabah42/malsabah42.vdi > signature.txt
# UTM (Apple Silicon):
shasum ~/Library/Containers/com.utmapp.UTM/Data/Documents/malsabah42.utm/Images/disk-0.qcow2 > signature.txt
```

Paste only the hash into `signature.txt`. Do not start the VM again after capturing it, or duplicate the disk first. No snapshots may exist at the start of an evaluation.

## Project description

### Operating system choice: Debian stable

Chosen: Debian stable.

Advantages: small netinst image, simple text installer, `apt` well documented, AppArmor enabled by default with low overhead, large 42 community knowledge base, predictable release cycle.

Disadvantages: older package versions than Rocky backports in some cases, no SELinux targeted policy out of the box, `sudo` and UFW need explicit install on minimal setups.

Rocky advantages: enterprise SELinux policies, `firewalld` zones, closer to RHEL production servers. Rocky disadvantages: heavier installer, more complex manual partitioning with encryption, KDump and SELinux troubleshooting cost, smaller peer knowledge base at most campuses. For a first server, Debian keeps the focus on the subject rules rather than on distribution complexity.

### Main design choices

* Partitioning: LVM on LUKS, separate `/`, `/home`, `/var`, `/srv`, `/tmp`, `/var/log`, plus swap. Fixed 20 GB disk satisfies mandatory and bonus layouts without waste. Full table in `docs/partitioning-20gb.md`.
* Security: SSH port 4242 only, `PermitRootLogin no`, UFW deny by default with single allow, password quality via `pwquality`, login defs for ageing, sudoers drop-in with logging.
* User management: root plus `malsabah` in `user42` and `sudo`. New evaluation users are added with `adduser` and `usermod -aG`.
* Services: only `ssh`, `ufw`, `cron`. No web stack in mandatory part. Bonus adds `lighttpd`, `MariaDB`, `PHP` for WordPress plus one extra service, with firewall rules adapted.

### Debian vs Rocky Linux

Debian uses `apt` with DEB packages and a community release process. Rocky uses `dnf` with RPM packages and tracks RHEL. Debian boots faster on a minimal VM and needs less RAM. Rocky gives stronger out of the box mandatory access control but needs more manual tuning for this subject. Either passes if the rules are met, but scripts and package names differ.

### AppArmor vs SELinux

AppArmor (Debian default) confines programs by path with profiles in `/etc/apparmor.d`, modes complain or enforce, managed with `aa-status`. SELinux (Rocky default, enforcing at boot for this project) labels every file and process with contexts and enforces type rules, managed with `sestatus`, `semanage`, `restorecon`. AppArmor is simpler to keep running for this project. SELinux is finer grained but blocks SSH on a nonstandard port or web services unless contexts and ports are adapted.

### UFW vs firewalld

UFW is a thin frontend to iptables/nftables (`ufw allow 4242/tcp`, `ufw enable`). firewalld is a zoned daemon (`firewall-cmd --add-port=4242/tcp --permanent`). UFW fits a single zone VM with one open port. firewalld fits multi zone servers with runtime and permanent rules. Both must be active at boot and leave only 4242 open for the mandatory part.

### VirtualBox vs UTM

VirtualBox is mandatory where available, stores `.vdi` under `~/VirtualBox VMs/`, sha1 via `sha1sum`. UTM is the fallback on Apple Silicon where VirtualBox cannot run, stores `.qcow2` under the UTM container, sha1 via `shasum`. Networking, shared folders, and snapshot menus differ, but subject rules (no snapshots at evaluation start, fixed disk, port forwarding for 4242) apply to both.

## Disk sizing

Fixed 20 GB virtual disk. It holds the mandatory LVM on LUKS layout plus the bonus WordPress layout with margin, while staying small enough to duplicate for signature capture and to push no VM image to git. Full arithmetic in `docs/partitioning-20gb.md`. The OVA reference in `docs/ova.md` uses the same 20 GB base.

## Resources

* Subject: `b2br.pdf` v5.2 (local copy in `~/Downloads/b2br.pdf`, 18 pages). Mandatory part pages 7-11, README requirements page 12, bonus page 14, submission pages 16-17.
* Debian installer guide: https://www.debian.org/releases/stable/installmanual
* LVM and LUKS: `man lvm`, `man cryptsetup`, Debian wiki Encrypted LVM.
* AppArmor: https://wiki.debian.org/AppArmor, `aa-status(8)`.
* UFW: https://wiki.ubuntu.com/UncomplicatedFirewall, `ufw(8)`.
* SSH hardening: `sshd_config(5)`, `ssh(1)`.
* Cron and wall: `crontab(5)`, `wall(1)`.
* OVA reference: https://drive.google.com/file/d/15najeg0HZuJo8OQYMoMlu5zakKXUsrdZ/view?usp=sharing (see `docs/ova.md`).
* AI use disclosure: AI was used to draft this README structure, the partitioning arithmetic, and the monitoring script template from the subject requirements. All values were checked against `b2br.pdf` v5.2 and Debian stable manuals. No VM image, password, or signature was generated by AI.

## Repository contents

* `README.md`: this file, subject compliant.
* `signature.txt`: sha1 of the VM disk, to be filled at submission.
* `monitoring.sh`: boot and cron broadcast script.
* `docs/how-i-did-it.md`: full step by step solution in order, with commands and expected outputs.
* `docs/verification.md`: copy paste checklist to run before signature.
* `docs/evaluation-qa.md`: questions asked at defense with short answers.
* `docs/commands-cheatsheet.md`: daily commands for host and VM.
* `docs/screenshots/`: required screenshot list with names, placeholders pending owner capture.
* `docs/subject-notes.md`: condensed notes from `b2br.pdf`.
* `docs/partitioning-20gb.md`: partition table and 20 GB justification.
* `docs/security-policy.md`: SSH, UFW, password, sudo steps.
* `docs/ova.md`: OVA link and handling notes.
* `PROJECT.md`, `AGENTS.md`: project maintenance notes.
