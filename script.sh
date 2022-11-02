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


# Montage du dossier partagé NFS depuis le poste client
mkdir -p /mnt/nfs/logs

# Montage du dossier NFS sur le serveur
mount -t nfs $nfspath /mnt/nfs/logs

# Création du dossier "Hostname"
mkdir /mnt/nfs/logs/"$HOSTNAME"

#Lancement de Nwipe avec l'option quick par défaut.
nwipe --method=$nwipemethod --logfile=$logpath/nwipe.log

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

#Affichage des résultats du test SMART Short
grep "# 1" $logpath/smart-short*.log

# On vérfie manuellement le résultat du test SMART Short, afin de lancer un test long si nécessaire
echo "Le resultat de la ligne # 1 renvoie \"Completed without error\" rentrer o pour oui, sinon taper sur la touche entree"
for i in o; do
    bash smart.sh long
    grep "#1" $logpath/smart-long*.log
done

#Suppression des fichiers PART et des résultats concernant les lecteurs optiques
rm $logpath/*-part*.log
rm $logpath/*DVD*.log

#Déplacement des fichiers log vers le dossier hostname
cp log/* /mnt/nfs/logs/"$HOSTNAME"/
