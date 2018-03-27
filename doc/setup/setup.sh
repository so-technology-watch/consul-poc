#!/bin/bash
# Script qui configure la machine afin de faire tourner consul
datacenter="nyc2"
data_dir="/var/consul"
log_level="DEBUG"
enable_syslog="true"
enable_ui="false"
#Regarde si l'execution est bien en root (i.e. sudo)
if [ $USER != "root" ]
then
    echo -e "Vous devez être root pour lancer ce progamme!"
    exit 1
fi
unzip=`which unzip`
if [[ $unzip == "" ]]; then
        echo -e "Ce progamme nécessite la présence du paquet unzip. Veuillez l'installer"
        exit 1
fi

#Si consul n'est pas présent dans le path, on l'installe
program=`which consul`
if [[ -z $program ]]; then
        echo "Installation de consul"
        architecture=`uname -m`

        if [[ $architecture == *"arm"* ]]; then
                arm_version=${architecture:3:1}
                if [[ arm_version -le 7 ]]; then #arm 32bits
                        LINK="https://releases.hashicorp.com/consul/1.0.2/consul_1.0.2_linux_arm.zip"
                else #arm 64bits
                        LINK="https://releases.hashicorp.com/consul/1.0.2/consul_1.0.2_linux_arm64.zip"
                fi

        elif [[ $architecture == *"64" ]]; then #architecture 64bits
                LINK="https://releases.hashicorp.com/consul/1.0.2/consul_1.0.2_linux_amd64.zip"

        else #architecture 32bits
                LINK="https://releases.hashicorp.com/consul/1.0.2/consul_1.0.2_linux_386.zip"
        fi

        DIR=`pwd`

        cd /usr/local/bin

        wget $LINK

        unzip *.zip

        rm -f *.zip

        cd $DIR
        echo "done"
fi
# Selection du nom de l'agent
printf "nom de l'agent au sein du cluster: "
read -e NAME

# Selection de l'adresse ip à bind au server et client
printf "nom de l'interface réseau à utiliser : "
read -e INTERFACE
IP_ADDR=`ifconfig $INTERFACE | grep "inet " | awk '{print $2}'`

# Demande des adresses ip des autres servers
printf "Entrer l'adresse IP de chaque server consul à joindre (ip_a ip_b ...) : "
read -e ip_servers_tmp
ip_array=( $ip_servers_tmp )
IP_SERVERS=""
for i in "${ip_array[@]}"; do
        if [[ $IP_SERVERS != "" ]]; then IP_SERVERS=$IP_SERVERS", "; fi
        IP_SERVERS=$IP_SERVERS"\""$i"\""
done

# Demande si activation de l'ui pour le client
printf "Activation de l'UI pour la config client ? [O/n] : "
read -e ui_response
while [[ "$ui_response" != "n" && "$ui_response" != "o" ]]; do
        printf "Entrée incorrecte. Entrer o ou n : "
        read -e ui_response
        echo $ui_response
done

if [[ "$ui_response" == "o" ]]; then
        enable_ui="true"
fi

# répertoires de conf
mkdir -p /etc/consul.d/{bootstrap,server,client}
mkdir -p $data_dir
echo "{
    \"bootstrap\": true,
    \"server\": true,
    \"datacenter\": \"$datacenter\",
    \"data_dir\": \"$data_dir\",
    \"log_level\": \"$log_level\",
    \"enable_syslog\": $enable_syslog,
        \"node_name\":\"$NAME\" }" > /etc/consul.d/bootstrap/config.json

echo "{
    \"bootstrap\": false,
    \"server\": true,
    \"datacenter\": \"$datacenter\",
    \"data_dir\": \"$data_dir\",
    \"log_level\": \"$log_level\",
    \"enable_syslog\": $enable_syslog,
    \"start_join\":[$IP_SERVERS],
        \"bind_addr\": \"$IP_ADDR\",
        \"node_name\":\"$NAME\" }" > /etc/consul.d/server/config.json

echo "{
    \"server\": false,
    \"datacenter\": \"$datacenter\",
    \"data_dir\": \"$data_dir\",
    \"ui\": $enable_ui,
    \"log_level\": \"$log_level\",
    \"enable_syslog\": $enable_syslog,
    \"start_join\": [$IP_SERVERS],
        \"bind_addr\": \"$IP_ADDR\",
        \"node_name\":\"$NAME\" }" > /etc/consul.d/client/config.json
echo "Setup terminé"

