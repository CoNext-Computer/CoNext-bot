#!/bin/bash
#Ce script permet de charger et lancer le script d' installation de l'outil d'inventaire
echo -n "adresse de téléchargement du script: "
read downloadsource
echo -n "Utilisateur pour AUTH Appache: "
read httpuser
echo -n "Mot de passe utilisateur pour AUTH Appache: "
read httppassword

#On télécharge le fichier d'installation du script
wget $downloadsource/install.sh

#On fait une sauvegarde de l'ancienne configuration et on télécharge une version vierge.
mv main.conf main.conf.bak
wget $downloadsource/main.conf

#On écrit l'adresse de téléchargement dans le fichier de configuration
sed -i "s|pathtoinstallfolder|$downloadsource|g" main.conf
sed -i "s|userforhttpauth|$httpuser|g" main.conf
sed -i "s|passwordforhttpauth|$httppassword|g" main.conf
bash install.sh
rm install.sh
