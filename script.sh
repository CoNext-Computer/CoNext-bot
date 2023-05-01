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


#STOCKAGE NFS#  Montage du dossier partagé NFS depuis le poste client
#mkdir -p /mnt/nfs/logs

#STOCKAGE NFS#  Montage du dossier NFS sur le serveur
#mount -t nfs $nfspath /mnt/nfs/logs

#STOCKAGE NFS# Création du dossier "Hostname"
#mkdir /mnt/nfs/logs/"$HOSTNAME"

#Lancement de Nwipe avec l'option quick , effacement automatique, excluant les volumes USB.
nwipe --method=$nwipemethod --nousb --autonuke --nowait --logfile=$logpath/nwipe.log

#Test de la RAM
#On détermine quelle quantité de mémoire et on retire 100M afin d'allouer un maximum de mémoire pour le test test.
ramfree=$(free -m | grep Mem | awk '{print $4}')
ramtest=$(($ramfree - 100))

#On lance le test de la mémoire
memtester $ramtest 1 >$logpath/memtest.log
cat $logpath/memtest.log

#Test du disque short
bash smart.sh short

#Suppression des fichiers PART et des résultats concernant les lecteurs optiques
rm $logpath/*-part*.log
rm $logpath/*DVD*.log
rm $logpath/*CD-ROM*.log

#Affichage des résultats du test SMART Short
grep "# 1" $logpath/smart-short*.log

# On vérfie manuellement le résultat du test SMART Short, afin de lancer un test long si nécessaire, on en profite pour supprimmer les résultats inintéressants.
echo "Le resultat de la ligne # 1 renvoie \"Completed without error\" rentrer o pour oui, sinon taper sur la touche entree"
for i in o; do
    bash smart.sh long
    grep "#1" $logpath/smart-long*.log
    rm $logpath/*-part*.log
    rm $logpath/*DVD*.log
    rm $logpath/*CD-ROM*.log
done

<<<<<<< HEAD
#Suppression des fichiers PART et des résultats concernant les lecteurs optiques
rm $logpath/*-part*.log
rm $logpath/*DVD*.log
rm $logpath/*CD-ROM*.log

#STOCKAGE NFS# Déplacement des fichiers log vers le dossier hostname
#cp $logpath/* /mnt/nfs/logs/"$HOSTNAME"/

#STOCKAGE FTP# Compression, rennomage de l'archive et déplacement des fichiers log vers le serveur

tar -czvf log-"$HOSTNAME".tar.gz $logpath/*
curl -T log-"$HOSTNAME".tar.gz ftp://"$ftpuser":"$ftppassword"@"$ftphost"/"$ftpdirectory"/
rm log-"$HOSTNAME".tar.gz
=======
#Déplacement des fichiers log vers le dossier hostname
cp log/* /mnt/nfs/logs/"$HOSTNAME"/
>>>>>>> 4075e08618c6ab5b281b83335b6b5eb0008b0200
