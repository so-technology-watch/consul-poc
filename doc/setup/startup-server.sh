#!/bin/bash

#Regarde si l'execution est bien en root (i.e. sudo)
if [ $USER != "root" ]
then
    echo -e "Vous devez être root pour lancer ce progamme!"
    exit 1
fi


# script de démarrage
echo "#!/bin/bash
exec consul agent -config-dir /etc/consul.d/server" > /usr/bin/consul-server

echo "
[Unit]
Description=Consul server process

Wants=network.target
After=network.target

[Service]
Type=simple

Restart=on-failure
ExecStart=/usr/bin/consul-server
RemainAfterExit=yes

[Install]
WantedBy=default.target"
 > /etc/systemd/system/consul-server.service

chmod 744 /usr/bin/consul-server
chmod 664 /etc/systemd/system/consul-server.service
systemctl daemon-reload
systemctl enable consul-server.service
