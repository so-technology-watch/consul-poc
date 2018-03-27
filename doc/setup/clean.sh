#!/bin/bash

#Regarde si l'execution est bien en root (i.e. sudo)
if [ $USER != "root" ]
then
    echo -e "Vous devez être root pour lancer ce progamme!"
    exit 1
fi

rm -rf /etc/consul.d
rm -rf /var/consul
rm -rf /etc/systemd/system/consul-client.service
rm -f /etc/systemd/system/consul-server.service
rm -f /usr/bin/consul-client
rm -f /usr/bin/consul-server
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
