# SSH Persistence & Systemd Backdoor Automation

A bash script that automates SSH key-based authentication setup and creates persistent backdoor access through systemd services. Designed for security testing and penetration testing scenarios.

## ⚠️ Disclaimer

This script is intended **exclusively for authorized security testing, penetration testing, and educational purposes** in controlled environments. Unauthorized access to computer systems is illegal. Always ensure you have explicit written permission before testing any system.

## 🎯 Purpose

This script demonstrates:
- SSH key-based authentication setup
- Privilege escalation and root SSH configuration
- Systemd service persistence techniques
- File immutability flags for anti-forensics
- Reverse shell payload delivery

## 📋 Prerequisites

- Bash shell
- SSH access to target system
- Sudo privileges on target (for persistence setup)
- Local SSH key pair (Ed25519)
- Network connectivity between attacker and target

## 🚀 Features

### 1. **SSH Key Authentication**
   - Generates Ed25519 SSH key if not present
   - Copies public key to target user account
   - Enables passwordless SSH authentication

### 2. **Root SSH Persistence**
   - Configures SSH daemon to allow root login
   - Copies authorized keys to root account
   - Sets proper permissions (700/600)

### 3. **Systemd Backdoor Service**
   - Creates hidden service in `/usr/local/bin/.sys_update`
   - Establishes reverse shell connection to attacker IP
   - Auto-restarts every 60 seconds on failure
   - Registered as system service for automatic startup

### 4. **Persistence Hardening**
   - Applies immutable flag (+i) to authorized_keys
   - Makes persistence difficult to remove
   - Survives system reboots

## 📝 Usage

```bash
bash ssh_script.sh
```

### Interactive Prompts:
```
Enter Target IP: 192.168.1.100
Enter Target Username (e.g., kali/admin): ubuntu
Enter Your Parrot IP (for reverse shell): 192.168.1.50
```

### Setup Listener (Before Running Script):
```bash
# On attacker machine, set up reverse shell listener
nc -lvnp 4444
```

## 🔧 Technical Details

### SSH Configuration Changes
- **sshd_config**: Enables `PermitRootLogin prohibit-password`
- **Authorized Keys**: Root's `~/.ssh/authorized_keys` receives attacker's public key

### Systemd Service
- **Service Name**: `sys-update.service`
- **Binary Location**: `/usr/local/bin/.sys_update` (hidden)
- **Type**: Simple service with automatic restart
- **Listener Port**: 4444 (configurable in script)

### Reverse Shell Details
- **Shell Type**: Bash interactive shell
- **Connection**: Persistent TCP back to attacker IP:4444
- **Reconnection**: Every 60 seconds if connection drops
- **Execution Context**: Root privileges

## 📊 Script Workflow

```
1. Gather Information (Target IP, Username, Local IP)
   ↓
2. Generate SSH Key Pair (if needed)
   ↓
3. Copy Public Key to Target User
   ↓
4. SSH into Target and Execute Escalation
   ├─ Configure Root SSH Access
   ├─ Copy Authorized Keys to Root
   ├─ Apply Immutable Flag
   ├─ Create Systemd Service
   ├─ Enable & Start Service
   └─ Restart SSH Daemon
   ↓
5. Persistence Established ✓
```

## 🛡️ Detection & Mitigation

### Detection Indicators:
- New service file: `/etc/systemd/system/sys-update.service`
- Hidden binary: `/usr/local/bin/.sys_update`
- Immutable flag on `/root/.ssh/authorized_keys`
- Outbound connections to reverse shell port
- Root SSH login attempts in auth logs

### Mitigation:
```bash
# Remove immutable flag
sudo chattr -i /root/.ssh/authorized_keys

# Disable service
sudo systemctl disable sys-update.service
sudo systemctl stop sys-update.service

# Remove service file
sudo rm /etc/systemd/system/sys-update.service
sudo systemctl daemon-reload

# Remove backdoor binary
sudo rm /usr/local/bin/.sys_update

# Review and clean SSH keys
sudo rm /root/.ssh/authorized_keys
```

## 🔑 Key Variables

| Variable | Purpose | Example |
|----------|---------|---------|
| `TARGET_IP` | Target system IP address | `192.168.1.100` |
| `TARGET_USER` | User account with sudo access | `ubuntu` |
| `LOCAL_IP` | Attacker's IP for reverse connection | `192.168.1.50` |

## 📚 Learning Resources

This script demonstrates several Linux security concepts:
- SSH key-based authentication
- Systemd service management
- Privilege escalation
- Persistence mechanisms
- Bash command chaining and redirection
- File permission and immutability (chattr)

## 📄 License

This project is provided for educational and authorized security testing purposes only.

## ⚡ Important Notes

- **Always get written authorization** before running on any system
- Test only in isolated lab environments
- This is a demonstration of attack techniques for defensive security purposes
- Misuse of this script is illegal and unethical

---

**Created for**: Security awareness, penetration testing training, and internship portfolio
