# Partitioning plan and 20 GB justification

Choice: fixed 20 GB VDI (not dynamic), Debian stable, LVM on LUKS.

## Why fixed 20 GB

* Subject says example sizes are arbitrary and asks for sizes that ensure proper operation while avoiding unnecessary disk usage. A fixed disk makes the signature deterministic and evaluation repeatable.
* 20 GB fits the mandatory layout plus the bonus WordPress layout with margin, while staying small enough to duplicate for signature capture, to export, and to keep host usage low.
* Dynamic disks grow unpredictably and change host file size during evaluation. Fixed allocation avoids that noise.
* Larger disks (40 GB and above) waste host space and slow down duplication and hashing. Smaller disks (8 to 12 GB) leave no room for `/var/log`, MariaDB, and WordPress uploads plus logs.

## Proposed table (20 GB disk)

Total: 20480 MB. EFI 512 MB (unencrypted), boot 1024 MB (unencrypted, ext4), LUKS PV remainder about 18900 MB.

LVM volume group `vg0` on LUKS:

* swap: 2048 MB
* `/` (root, ext4): 4096 MB
* `/var` (ext4): 3072 MB
* `/var/log` (ext4): 2048 MB, separate so logs cannot fill root, keeps sudo logs in `/var/log/sudo/`
* `/home` (ext4): 3072 MB
* `/srv` (ext4, WordPress data for bonus): 3072 MB
* `/tmp` (ext4, nodev nosuid noexec): 1024 MB
* free reserve in VG: about 1400 MB for snapshots during defense or LVM growth

All LVM logical volumes except swap are ext4. At least 2 encrypted partitions requirement is met because the whole PV is LUKS encrypted and each LV inherits it; `/home` and `/var` count as separate encrypted volumes at evaluation.

## Bonus fit

* Bonus partition structure from subject page 14 maps to the same table with `/srv` hosting lighttpd and WordPress PHP files and `/var` hosting MariaDB data.
* MariaDB default data in `/var/lib/mysql` stays inside the 3072 MB `/var`. Logs in `/var/log` stay isolated.
* Extra service (example: fail2ban or Prometheus node exporter, not NGINX or Apache2) needs under 500 MB including logs, covered by the VG reserve.

## Verification

```bash
lsblk -o NAME,SIZE,TYPE,MOUNTPOINT,FSTYPE
sudo vgs && sudo lvs
cryptsetup status $(ls /dev/mapper/*crypt* | head -1)
df -h
```

Pass criteria: `lsblk` shows `crypt` type, `lvs` shows all volumes, `df` total near 19 GB usable, no desktop packages installed.
