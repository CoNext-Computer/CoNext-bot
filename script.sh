#!/bin/bash
#On demande le numéro inventaire afin de faire concorder le hostname avec celui-ci pour GLPI et le partage NFS
echo -n "Numéro Inventaire?: "
read HOSTNAME
hostnamectl set-hostname $HOSTNAME

#Une mise à jour des dépôts ne fait jamais de mal
sudo apt update

#Supression des fichiers log 
rm log/*.log 

#Execution de glpi-agent afin deffectuer linventaire
glpi-agent --logfile=log/glpi.log


# Montage du dossier partagé NFS depuis le poste client 
mkdir -p /mnt/nfs/logs

# Montage du dossier NFS sur le serveur
mount -t nfs 192.168.1.204:/mnt/Basic/Publique/Atelier/Logs /mnt/nfs/logs

# Création du dossier "Hostname" 
mkdir /mnt/nfs/logs/"$HOSTNAME"

#Lancement de Nwipe avec l'option quick par défaut.
nwipe --method=quick --logfile=log/nwipe.log

#Test du disque short
bash smart.sh short

#Suppression des fichiers PART 
rm log/*-part*.log

#Déplacement des fichiers log vers le dossier hostname 
cp log/* /mnt/nfs/logs/"$HOSTNAME"/

