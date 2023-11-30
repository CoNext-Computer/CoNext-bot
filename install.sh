#!/bin/bash
#Ce script permet d'installer tous les packets nécessaires pour l'inventaire

#Appel du fichier de configuration
. main.conf

#Une mise à jour des dépôts ne fait jamais de mal
apt update
apt upgrade -y

#Installation de SNAP (obligatoire pour glpi-agent)
apt install -y -f snap

#création du répertoire log
mkdir $logpath

#Installation de l'agent glpi inventory
rm glpi-agent-*-with-snap-linux-installer.pl
wget $glpiagentinstallurl || { echo "Échec du téléchargement de glpi"; exit 1; }
perl glpi-agent-*-with-snap-linux-installer.pl
rm glpi-agent-*-with-snap-linux-installer.pl

#On rajoute les identifiants dans le fichier de configuration glpi-agent
sed -i "s|user =|user = $httpuser|g" /etc/glpi-agent/agent.cfg
sed -i "s|password =|password = $httppassword|g" /etc/glpi-agent/agent.cfg

#Installation des packets NFS Client
apt install -y -f nfs-common


#Installation de NWipe, logiciel d'effacement de disques
apt install -y -f nwipe

#Installation de memtester, logiciel de test de la mémoire ramfree
apt install -y -f memtester

# Nettoyage et installation du script principal et du script de test des disques durs
rm script.sh
rm smart.sh
wget $downloadsource/script.sh || { echo "Échec du téléchargement de script.sh"; exit 1; }
wget $downloadsource/smart.sh || { echo "Échec du téléchargement de smart.sh"; exit 1; }
wget $downloadsource/inventory.dumb || { echo "Échec du téléchargement de inventory.dumb"; exit 1; }
