#!/usr/bin/env bash
set -e

echo "Grabbing IPs..."
PRIVATE_IP=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)

echo "Installing dependencies..."
sudo apt-get -q update
sudo apt-get -yq install unzip

cat << EOF >/etc/systemd/resolved.conf
[Resolve]
DNS=127.0.0.1:8600
Domains=~consul
EOF

systemctl restart systemd-resolved.service

consul_version="1.15.2"

echo "Fetching Consul..."
cd /tmp
curl -sLo consul.zip https://releases.hashicorp.com/consul/${consul_version}/consul_${consul_version}_linux_amd64.zip

echo "Installing Consul..."
unzip consul.zip >/dev/null
sudo chmod +x consul
mv consul /usr/local/bin/consul

#Variables
opt="/opt/consul"
etc="/etc/consul.d"

# Setup Consul
sudo mkdir -p "$opt"
sudo mkdir -p "$etc"

tee "$etc/config.json" > /dev/null <<EOF
{
  "advertise_addr": "$PRIVATE_IP",
  "data_dir": "$opt",
  "datacenter": "opsschool",
  "encrypt": "uDBV4e+LbFW3019YKPxIrg==",
  "disable_remote_exec": true,
  "disable_update_check": true,
  "leave_on_terminate": true,
  "retry_join": ["provider=aws tag_key=Consul tag_value=server"],
  ${config}
}
EOF

# Create user & grant ownership of folders
useradd consul
sudo chown -R consul:consul "$opt" "$etc"


# Configure consul service
tee /etc/systemd/system/consul.service > /dev/null <<EOF
[Unit]
Description=Consul service discovery agent
Requires=network-online.target
After=network.target

[Service]
User=consul
Group=consul
PIDFile="$opt/consul.pid"
Restart=on-failure
Environment=GOMAXPROCS=2
ExecStart=/usr/local/bin/consul agent -pid-file="$opt/consul.pid" -config-dir="$etc"
ExecReload=/bin/kill -s HUP \$MAINPID
KillSignal=SIGINT
TimeoutStopSec=5

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable consul.service
sudo systemctl start consul.service


