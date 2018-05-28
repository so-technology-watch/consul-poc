#!/bin/bash

#Regarde si l'execution est bien en root (i.e. sudo)
if [ $USER != "root" ]
then
    echo -e "Vous devez être root pour lancer ce progamme!"
    exit 1
fi

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
