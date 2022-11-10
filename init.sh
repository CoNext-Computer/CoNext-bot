#!/bin/bash
#Ce script permet de charger et lancer le script d' installation de l'outil d'inventaire
echo -n "adresse de téléchargement du script: "
read downloadsource

#On télécharge le fichier d'installation du script
wget $downloadsource/install.sh

#On fait une sauvegarde de l'ancienne configuration et on télécharge une version vierge.
mv main.conf main.conf.bak
wget $downloadsource/main.conf

#On écrit l'adresse de téléchargement dans le fichier de configuration
sed -i "s|pathtoinstallfolder|$downloadsource|g" main.conf
bash install.sh
rm install.sh
