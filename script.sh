#!/bin/bash
#On demande le numéro inventaire afin de faire concorder le hostname avec celui-ci pour GLPI et le partage NFS

. main.conf

echo -n "Numero Inventaire?: "
read ninventaire
hostnamectl set-hostname $ninventaire

#Une mise à jour des dépôts ne fait jamais de mal
sudo apt update

#Supression des fichiers log
rm $logpath/*.log

#Execution de glpi-agent afin deffectuer linventaire
glpi-agent --logfile=$logpath/glpi.log



                # A supprimer si utilisation de FTP
######################################################################

#STOCKAGE NFS#  Montage du dossier partagé NFS depuis le poste client
mkdir -p /mnt/nfs/logs

#STOCKAGE NFS#  Montage du dossier NFS sur le serveur
mount -t nfs $nfspath /mnt/nfs/logs

#STOCKAGE NFS# Création du dossier "Hostname"
mkdir /mnt/nfs/logs/"$HOSTNAME"

######################################################################




#Lancement de Nwipe avec l'option quick , effacement automatique, excluant les volumes USB.
nwipe --method=$nwipemethod --nousb --autonuke --nowait --logfile=$logpath/nwipe.log



#Test de la RAM
#On détermine quelle quantité de mémoire et on retire 100M afin d'allouer un maximum de mémoire pour le test test.
ramfree=$(free -m | grep Mem | awk '{print $4}')
ramtest=$(($ramfree - 100))

#On lance le test de la mémoire
memtester $ramtest 1 >$logpath/memtest.log
cat $logpath/memtest.log



#On lance un smart test long.
bash smart.sh long

#Affichage des résultats du test long.
grep "#1" $logpath/smart-long*.log

#On supprimme les résultats inintéressants.
rm $logpath/*-part*.log
rm $logpath/*DVD*.log
rm $logpath/*CD-ROM*.log


            # A décommenter si utilisation de FTP
####################################################################

#STOCKAGE FTP # Compression, rennomage de l'archive et déplacement des fichiers log vers le serveur

#tar -czvf log-"$HOSTNAME".tar.gz $logpath/*
#curl -T log-"$HOSTNAME".tar.gz ftp://"$ftpuser":"$ftppassword"@"$ftphost"/"$ftpdirectory"/
#rm log-"$HOSTNAME".tar.gz
#####################################################################


#Déplacement des fichiers log vers le dossier hostname
cp $logpath/* /mnt/nfs/logs/"$HOSTNAME"/

systemctl poweroff