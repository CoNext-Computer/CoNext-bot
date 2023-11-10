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

#Une mise à jour des dépôts ne fait jamais de mal
sudo apt update

#Supression des fichiers log
rm $logpath/*.log

#Execution de glpi-agent afin deffectuer linventaire
glpi-agent --additional-content="inventory.json" --logfile=$logpath/glpi.log

rm inventory.json



                # A supprimer si utilisation de FTP
######################################################################

#STOCKAGE NFS#  Montage du dossier partagé NFS depuis le poste client
mkdir -p /mnt/nfs/logs

#STOCKAGE NFS#  Montage du dossier NFS sur le serveur
mount -t nfs $nfspath /mnt/nfs/logs

#STOCKAGE NFS# Création du dossier "ninventaire"
mkdir /mnt/nfs/logs/"$ninventaire"

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


#STOCKAGE NFS# Déplacement des fichiers log vers le dossier niventaire
cp $logpath/* /mnt/nfs/logs/"$ninventaire"/

            # A décommenter si utilisation de FTP
####################################################################

#STOCKAGE FTP # Compression, rennomage de l'archive et déplacement des fichiers log vers le serveur

#tar -czvf log-"$ninventaire".tar.gz $logpath/*
#curl -T log-"$ninventaire".tar.gz ftp://"$ftpuser":"$ftppassword"@"$ftphost"/"$ftpdirectory"/
#rm log-"$ninventaire".tar.gz
#####################################################################

systemctl poweroff