#!/bin/bash

# script de démarrage
echo "#!/bin/bash
exec consul agent -config-dir /etc/consul.d/client" > /usr/bin/consul-client

echo "
[Unit]
Description=Consul client process
Wants=network.target
After=network.target

[Service]
Type=simple
ExecStart=/usr/bin/consul-client

[Install]
WantedBy=default.target" > /etc/systemd/system/consul-client.service

chmod 774 /usr/bin/consul-client
chmod 664 /etc/systemd/system/consul-client.service
systemctl daemon-reload
systemctl enable consul-client.service
