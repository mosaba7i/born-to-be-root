# Screenshots

Place PNG files in this folder with exact names below. Keep each under 1 MB (1280 px wide, compressed). No passwords or keys visible. Blur MAC octets if needed.

## Required list

* `01-vm-settings.png`: VirtualBox system, storage with ISO, network with 4242 forwarding.
* `02-partition-table.png`: Manual partitioning, EFI plus boot plus encrypted PV.
* `03-lvm-layout.png`: Volume group vg0 with all LVs and mount points.
* `04-software-selection.png`: Only SSH server and standard utilities checked, no desktop.
* `05-id-malsabah.png`: Output of `id malsabah` showing user42 and sudo.
* `06-ssh-4242.png`: `ss -tlnp | grep 4242` plus successful login on 4242.
* `07-ufw-status.png`: `ufw status numbered` with only 4242 open.
* `08-chage-policy.png`: `chage -l malsabah` with 30/2/7.
* `09-sudo-log.png`: `ls /var/log/sudo/` and custom badpass message.
* `10-apparmor-status.png`: `aa-status` enforce output.
* `11-wall-broadcast.png`: Terminal showing wall message with all 11 fields.

## How to capture

* VirtualBox: View, Take Screenshot, or host `import` for host side. UTM: share screen capture.
* In VM terminal, run `clear` before capture, enlarge font with Ctrl+Shift+Plus.
* Name files exactly as above so `docs/how-i-did-it.md` links stay valid.

Current status: placeholders pending. Add files, then commit only PNGs listed here.
