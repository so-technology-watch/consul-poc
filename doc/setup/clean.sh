#!/bin/bash

#Regarde si l'execution est bien en root (i.e. sudo)
if [ $USER != "root" ]
then
    echo -e "Vous devez être root pour lancer ce progamme!"
    exit 1
fi

server_service="/etc/systemd/system/consul-server.service"
client_service="/etc/systemd/system/consul-client.service"

rm -rf /etc/consul.d
rm -rf /var/consul
rm -f /usr/bin/consul-client
rm -f /usr/bin/consul-server


if [[ -e $server_service ]]; then
        echo "consul-server.service trouvé. Suppression..."
        systemctl stop consul-server.service
        systemctl disable consul-server.service
        rm -f /etc/systemd/system/consul-server.service
fi

if [[ -e $client_service ]]; then
        echo "consul-client.service trouvé. Suppression..."
        systemctl stop consul-client.service
        systemctl disable consul-client.service
        rm -f /etc/systemd/system/consul-client.service
fi
systemctl daemon-reload

consul_binary=`which consul`
if [[ ! -z $consul_binary ]]; then
	printf "consul trouvé, suppression ? (y/n) "
	responseOk=0
	shopt -s nocasematch # Comparaison string sans la casse
	while [[ responseOk -ne 1 ]]; do
		read -e response
		
		if [[ $response == "y" ]] || [[ $response == "o" ]]; then
			responseOk=1
			rm -f $consul_binary
			
		elif [[ $response == "n" ]]; then
			responseOk=1
		else
			echo "Répondre par y ou n"
		fi
	
	done
fi
