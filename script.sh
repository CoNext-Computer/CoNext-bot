#!/bin/bash
#On demande le numéro d'inventaire afin de l'intégrer dans GLPI et pour la sauvegarde des fichiers logs sur le serveur NFS/FTP

. main.conf

while true; do
    # Validation du numéro d'inventaire
    echo -n "Numéro Inventaire?: "
    read ninventaire

    # Vérification de la validité du numéro d'inventaire (doit commencer par deux lettres et être suivi de 9 chiffres)
    if [[ "$ninventaire" =~ ^[A-Za-z]{2}[0-9]{9}$ ]]; then
        break  # Sortir de la boucle si le numéro est valide
    else
        echo "Erreur : Numéro d'inventaire non valide. Doit commencer par deux lettres et être suivi de 9 chiffres."
    fi
done

#on fait une copie du fichier modele afin de garder un original propre, puis on remplace le texte "dumbname"
cp inventory.dumb inventory.json
grep -q "dumbname" inventory.json && sed -i "s/dumbname/${ninventaire}/g" inventory.json
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


# Fonction pour effectuer un test SMART
perform_smart_test() {
    local test_type=$1
    bash smart.sh "$test_type"

    # Suppression des résultats inintéressants.
	rm "$logpath"/*-{part*,DVD*,CD-ROM*}.log
}

# Lancement d'un test court du disque
perform_smart_test short

# Vérification du résultat du test court
if grep -q "completed without error" "$logpath/smart-short*.log"; then
    echo "Le test court du disque a réussi. Lancement du test long."

    # Lancement d'un test long du disque
    perform_smart_test long

    # Vérification du résultat du test long
    if grep -q "completed without error" "$logpath/smart-long*.log"; then
        echo "Le test long du disque a réussi."
    else
        echo "Le test long du disque a échoué."
    fi
else
    echo "Le test court du disque a échoué. Aucun test long ne sera effectué."
fi


#STOCKAGE NFS# Déplacement des fichiers log vers le dossier ninventaire
cp $logpath/* /mnt/nfs/logs/"$ninventaire"/

            # A décommenter si utilisation de FTP
####################################################################

#STOCKAGE FTP # Compression, rennomage de l'archive et déplacement des fichiers log vers le serveur

#tar -czvf log-"$ninventaire".tar.gz $logpath/*
#curl -T log-"$ninventaire".tar.gz ftp://"$ftpuser":"$ftppassword"@"$ftphost"/"$ftpdirectory"/
#rm log-"$ninventaire".tar.gz
#####################################################################

systemctl poweroff