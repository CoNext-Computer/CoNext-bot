#!/bin/bash
#On demande le numéro d'inventaire afin de l'intégrer dans GLPI et pour la sauvegarde des fichiers logs sur le serveur NFS/FTP

. main.conf

#On récupere le numero dinventaire
echo -n "Numero Inventaire?: "
read ninventaire

#on fait une copie du fichier modele afin de garder un original propre, puis on remplace le texte "dumbname"
cp inventory.dumb inventory.json
grep -q "dumbname" inventory.json | sed -i "s/dumbname/${ninventaire}/g" inventory.json
echo 'Le nom de machine dans GLPI est : '$ninventaire

#Supression des fichiers log
rm $logpath/*.log

#Execution de glpi-agent afin deffectuer linventaire
glpi-agent --additional-content="inventory.json" --logfile=$logpath/glpi.log

rm inventory.json


#STOCKAGE NFS#  Montage du dossier partagé NFS depuis le poste client
mkdir -p /mnt/nfs/logs

#STOCKAGE NFS#  Montage du dossier NFS sur le serveur
mount -t nfs $nfspath /mnt/nfs/logs

#STOCKAGE NFS# Création du dossier "ninventaire"
mkdir /mnt/nfs/logs/"$ninventaire"

#STOCKAGE NFS# Déplacement des fichiers log vers le dossier niventaire
cp $logpath/* /mnt/nfs/logs/"$ninventaire"/

systemctl poweroff