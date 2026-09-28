# OVA reference

URL: https://drive.google.com/file/d/15najeg0HZuJo8OQYMoMlu5zakKXUsrdZ/view?usp=sharing

## Handling

* The OVA is a reference import only. Do not commit it to git (see `.gitignore` for `*.ova`).
* Import path: VirtualBox Manager, File, Import Appliance, select the downloaded OVA, accept 20 GB fixed base disk.
* After import, rename the VM to `malsabah42`, set hostname inside the guest to `malsabah42`, regenerate SSH host keys if the OVA ships with any, and change all passwords per `docs/security-policy.md`.
* Capture the signature from your own `.vdi` after setup, not from the downloaded OVA file. The OVA hash and the installed disk hash differ.
* Large media note: previous attachments were removed because they exceeded provider size limits. This repo keeps only the link and text notes. Provide smaller files if a re-import is needed.
