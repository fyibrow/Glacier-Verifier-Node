#!/bin/bash

# Buat direktori Glacier
mkdir -p ~/glacier

# Download verifier
wget https://github.com/Glacier-Labs/node-bootstrap/releases/download/v0.0.2-beta/verifier_linux_amd64 -O ~/glacier/verifier_linux_amd64

# Minta input Private Key
read -p "Masukkan Private Key Anda: " private_key

# Buat file config.yaml
cat << EOF > ~/glacier/config.yaml
Http:
  Listen: "127.0.0.1:10801"
Network: "testnet"
RemoteBootstrap: "https://glacier-labs.github.io/node-bootstrap/"
Keystore:
  PrivateKey: "$private_key"
TEE:
  IpfsURL: "https://greenfield.onebitdev.com/ipfs/"
EOF

# Ubah izin file verifier agar dapat dieksekusi
chmod +x ~/glacier/verifier_linux_amd64

# Buat direktori untuk konfigurasi di /etc
sudo mkdir -p /etc/glaciernetwork

# Salin file konfigurasi ke lokasi yang tepat
sudo cp ~/glacier/config.yaml /etc/glaciernetwork/config

# Buat file konfigurasi systemd
cat << EOF | sudo tee /etc/systemd/system/glacier.service
[Unit]
Description=Glacier Node Service
After=network.target

[Service]
ExecStart=/root/glacier/verifier_linux_amd64
Restart=on-failure
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd dan aktifkan layanan
sudo systemctl daemon-reload
sudo systemctl enable glacier.service
sudo systemctl start glacier.service

echo "Node Anda sudah siap dijalankan sebagai layanan systemd!"
echo "Anda dapat memantau log dengan perintah: journalctl -u glacier.service -f"

