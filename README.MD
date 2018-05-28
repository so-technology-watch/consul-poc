# Mise en place de consul

Lancer le script `setup.sh` qui va installer consul s'il ne le trouve pas sur le disque.
Puis générer un fichier de configuration en fonction des informations saisies.

Ensuite il suffit de faire :
	`consul agent -config-dir etc/consul.d{server/client/bootstrap}/config.json`

## Service système
Afin d'avoir l'agent consul qui tourne en permanence sur la machine et qui le lance automatiquement au démarrage vous pouvez lancer le script `startup-client.sh`ou `startup-server.sh`. 
Il faut ensuite faire appel à `systemctl` pour arrêter, lancer ou voir le statut sur service et `journalctl` pour voir les logs.

## Nettoyer le système
Le script `clean.sh` va nettoyer tous les répertoires crées par les autres scripts et supprimer les services crées par les scripts `startup-*`.