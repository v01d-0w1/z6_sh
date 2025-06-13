#!/bin/bash
set -e

echo "[*] Installing required packages..."
sudo xbps-install -Sy libvirt virt-manager qemu

echo "[*] Enabling libvirtd service..."
sudo ln -sf /etc/sv/libvirtd /var/service/
sleep 2
sudo sv restart libvirtd

echo "[*] Enabling virtlogd service..."
if [ ! -e /var/service/virtlogd ]; then
    sudo ln -s /etc/sv/virtlogd /var/service/
    sleep 2
fi
sudo sv restart virtlogd

echo "[*] Ensuring user is in the 'libvirt' group..."
if ! id -nG "$USER" | grep -qw libvirt; then
    echo "[-] You are not in the 'libvirt' group. Adding you now..."
    sudo usermod -aG libvirt "$USER"
    echo "[!] Please log out and log back in for group changes to take effect."
fi

echo "[*] Creating libvirt default NAT network XML..."
sudo mkdir -p /etc/libvirt/qemu/networks

sudo tee /etc/libvirt/qemu/networks/default.xml > /dev/null <<EOF
<network>
  <name>default</name>
  <uuid>a7905021-0b5e-41c2-9a17-2a92f2ab7240</uuid>
  <forward mode='nat'/>
  <bridge name='virbr0' stp='on' delay='0'/>
  <mac address='52:54:00:d5:12:dd'/>
  <ip address='192.168.122.1' netmask='255.255.255.0'>
    <dhcp>
      <range start='192.168.122.2' end='192.168.122.254'/>
    </dhcp>
  </ip>
</network>
EOF

echo "[*] Cleaning up any existing default network..."
sudo virsh net-destroy default 2>/dev/null || true
sudo virsh net-undefine default 2>/dev/null || true

echo "[*] Defining and starting new default network..."
sudo virsh net-define /etc/libvirt/qemu/networks/default.xml
sudo virsh net-start default
sudo virsh net-autostart default

echo "[*] Bringing up virbr0 interface..."
sudo ip link set virbr0 up || true

echo "[✔] Setup complete!"
virsh net-list --all
ip a show virbr0

