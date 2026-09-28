# Subject notes from b2br.pdf v5.2

Source: `~/Downloads/b2br.pdf`, 18 pages, pdfTeX 1.40.24, dated 2026-02-02. Summary below, not a replacement for the PDF.

## Preamble and intro

System administration exercise. Create a first VM in VirtualBox (or UTM if VirtualBox is unavailable). No graphical server: X.org, Wayland, or equivalent is forbidden, grade 0 otherwise.

## General guidelines

* VirtualBox or UTM mandatory.
* Submit only `signature.txt` and `README.md` at repo root.
* No snapshots at the start of each evaluation.

## Mandatory part

* OS: latest stable Debian or Rocky. Debian recommended for beginners. Rocky skips KDump setup, but SELinux must run at boot. Debian AppArmor must run at boot.
* At least 2 encrypted partitions using LVM. Sizes in the subject are arbitrary: choose sizes that work without waste.
* Know the OS for defense: aptitude vs apt, SELinux or AppArmor.
* SSH on port 4242, running. Root SSH login forbidden. Tested with a new account during defense.
* Firewall UFW (Debian) or firewalld (Rocky), only port 4242 open, active at boot.
* Hostname `<login>42`, here `malsabah42`. Changed during peer review.
* Extra user named after login, in `user42` and `sudo` groups. New user creation tested during review.
* Password policy: expire every 30 days, minimum 2 days between changes, warning 7 days before expiry, min 10 chars with upper, lower, digit, max 3 identical consecutive chars, no username inside, at least 7 chars different from previous password (root exempt from this one rule). Root password complies. Change all passwords after configuring files.
* Sudo: max 3 attempts, custom badpass message, log inputs and outputs to `/var/log/sudo/`, TTY required, restricted secure path (example `/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin`).
* Script `monitoring.sh` in bash, shown on all terminals at startup and every 10 minutes via wall. No errors. Reports architecture and kernel, physical CPU, vCPU, RAM use and percent, disk use and percent, CPU load percent, last reboot date, LVM yes/no, TCP established count, logged users count, IPv4 and MAC, sudo command count. Example output on subject page 10. Must be able to explain it and stop it without modifying it. Uses cron.

## Readme requirements

First line italic: *This project has been created as part of the 42 curriculum by ...*. Sections: Description, Instructions, Resources with AI use disclosure. Project description section must explain OS choice with pros and cons, main design choices (partitioning, security, users, services), and compare Debian vs Rocky, AppArmor vs SELinux, UFW vs firewalld, VirtualBox vs UTM.

## Bonus part

Only evaluated if mandatory is perfect.

* Replicate the bonus partition structure from the subject.
* Functional WordPress with lighttpd, MariaDB, PHP.
* One extra service of choice (NGINX and Apache2 excluded), justified at defense.
* Extra ports may be opened, firewall adapted.

## Submission and peer evaluation

* Get disk signature from default VM folder: Windows `%HOMEDRIVE%%HOMEPATH%\VirtualBox VMs\`, Linux `~/VirtualBox VMs/`, Mac M1 UTM `~/Library/Containers/com.utmapp.UTM/Data/Documents/`, macOS `~/VirtualBox VMs/`.
* Hash the `.vdi` (or `.qcow2` for UTM) with sha1: `certUtil -hashfile`, `sha1sum`, or `shasum`. Paste into `signature.txt`.
* Signature changes on next boot: duplicate the disk or use per evaluation snapshots.
* Never include the VM in git. Mismatched signature gives grade 0.
* Each defense starts with no snapshots, one snapshot is created then deleted during defense.
* Small live modification may be requested to prove understanding.
