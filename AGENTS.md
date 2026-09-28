# Build instructions (for the born-to-be-root agent)

You are maintaining the Born2beRoot repo for login malsabah.

> Debian stable server in VirtualBox/UTM per b2br.pdf v5.2. Hardened SSH, UFW, password policy, sudo logging, monitoring.sh, 20 GB fixed disk.

Requirements:

* Keep README.md subject compliant: first line italic with author, Description, Instructions, Resources with AI disclosure, OS comparison (Debian vs Rocky, AppArmor vs SELinux, UFW vs firewalld, VirtualBox vs UTM).
* Never commit VM images (*.vdi, *.qcow2, *.ova), passwords, hashes, or real signatures except the final sha1 in signature.txt.
* Keep monitoring.sh POSIX bash, no errors on stdout/stderr when values are missing, wall broadcast compatible.
* Keep partitioning docs consistent with fixed 20 GB justification.

## Maintain PROJECT.md (mandatory, every run)

`PROJECT.md` at the repo root is the living documentation. On EVERY run:

1. Read the existing `PROJECT.md` first. Never delete old history.
2. Update Overview and How to run if reality changed.
3. Append a new dated section under Build history with date, what happened, how/technique, files changed, decisions and trade-offs, known issues/next steps.
4. Keep it in English, concise but complete. Commit together with work.
