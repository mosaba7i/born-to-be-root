# Command cheatsheet (my daily use)

## Host

```bash
# ssh into VM
ssh -p 4242 malsabah@localhost
# copy monitoring script into VM
scp -P 4242 monitoring.sh malsabah@localhost:/tmp/
# signature after shutdown
sha1sum ~/VirtualBox\ VMs/malsabah42/malsabah42.vdi
```

## VM basics

```bash
hostnamectl
lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINT
sudo vgs && sudo lvs
df -h
id malsabah
```

## Services

```bash
sudo systemctl status ssh --no-pager
sudo ss -tlnp | grep 4242
sudo ufw status numbered
sudo aa-status | head -n 30
```

## Users and passwords

```bash
sudo adduser newuser
sudo usermod -aG user42 newuser
chage -l malsabah
sudo passwd malsabah
```

## Sudo test

```bash
sudo visudo -c
sudo -k; sudo whoami
ls -l /var/log/sudo/
sudo cat /var/log/sudo/sudo.log | tail -n 50
```

## Monitoring

```bash
bash -n /usr/local/bin/monitoring.sh
sudo /usr/local/bin/monitoring.sh
sudo crontab -l
sudo pkill -f monitoring.sh || true
```

## Logs for defense

```bash
journalctl -u ssh --no-pager | tail -n 30
sudo dmesg | grep -i apparmor | tail -n 20
sudo cat /var/log/auth.log | tail -n 30
```
