#!/bin/bash
#Ce script permet d'installer tous les packets nécessaires pour l'inventaire

#Une mise à jour des dépôts ne fait jamais de mal
apt update
apt upgrade

#Installation de SNAP (obligatoire pour glpi-agent)
apt install -y -f snap

#création du répertoire log
mkdir log

#Installation de l'agent glpi inventory
rm glpi-agent-1.4-with-snap-linux-installer.pl
wget https://github.com/glpi-project/glpi-agent/releases/download/1.4/glpi-agent-1.4-with-snap-linux-installer.pl
perl glpi-agent-1.4-with-snap-linux-installer.pl
rm glpi-agent-1.4-with-snap-linux-installer.pl


#Installation des packets NFS Client (
apt install -y -f nfs-common


#Installation de NWipe, logiciel d'effacement de disques
apt -y -f install nwipe

# Nettoyage et installation du script principal et du script de test des disques durs
rm script.sh
rm smart.sh
wget http://conext.computer/script.sh
wget http://conext.computer/smart.sh
