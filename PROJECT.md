# born-to-be-root: Project Documentation

> Living document. Every build/update appends a dated section below, explaining what happened and the technique used, so anyone can read this and continue the project from where it stands.

## Overview

* **Idea:** Born2beRoot 42 server in VirtualBox/UTM, Debian stable, hardened per b2br.pdf v5.2.
* **Status:** Scaffolded with subject notes, monitoring script, and 20 GB partitioning plan. VM install and signature capture pending by owner.
* **Login:** malsabah, hostname malsabah42, OS Debian, disk 20 GB fixed.
* **OVA:** https://drive.google.com/file/d/15najeg0HZuJo8OQYMoMlu5zakKXUsrdZ/view?usp=sharing

## How to run

No build step. This repo is docs plus scripts.

1. Follow README Instructions to install the VM.
2. Copy monitoring.sh to the VM and register cron rules.
3. Capture sha1 into signature.txt before evaluation.

Checks: `bash -n monitoring.sh`, `shellcheck monitoring.sh` if available.

## Build history

### 2026-09-28: initial scaffold

* **Date:** 2026-09-28
* **What happened:** Created repo structure from b2br.pdf v5.2. Added subject compliant README, monitoring.sh, signature.txt placeholder, docs for partitioning with 20 GB justification, security policy, subject notes, and OVA reference, plus PROJECT.md and AGENTS.md.
* **How / technique:** Read local ~/Downloads/b2br.pdf (18 pages). Used new-project-scaffold skeleton and technical-writing style. Chose Debian per user answer. Sized partitions to fit mandatory and bonus layouts inside fixed 20 GB.
* **Files changed:** README.md, PROJECT.md, AGENTS.md, .gitignore, signature.txt, monitoring.sh, docs/subject-notes.md, docs/partitioning-20gb.md, docs/security-policy.md, docs/ova.md.
* **Decisions and trade-offs:** Fixed 20 GB (not dynamic) for deterministic signature and evaluation. Debian over Rocky for simpler AppArmor and UFW path. OVA kept as link only, never committed.
* **Known issues / next steps:** Owner must perform the VM install, test wall broadcasts, run ufw and sshd checks, then paste real sha1 into signature.txt.
