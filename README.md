# CoNext-bot V2.0

Ce script, découpé en plusieurs fichiers permet d'utiliser un environnement d'inventorisation via un agent GLPI, effacer un/des disques via NWipe et de tester les disques durs tout en consignant le résultat des opérations dans un répertoire réseau.

Il est étudié pour une installation sur une distribution Linux basée sur Debian (testé avec Debian-Live 11.5 sans interface graphique).

* ***init.sh***
Permet de récupérer automatiquement la dernière version de l'installateur du script (install.sh) depuis un chemin réseau / adresse web.

* ***install.sh***
Permet d'installer l'agent GLPI, installe les paquets nécessaires à l'accès d'un serveur nfs, nwipe et télécharge le script général (script.sh), le script permettant le test des disques durs (smart.sh) ainsi que le logiciel de test de mémoire vive memtester.

* ***script.sh***
Permet à l'utilisateur final de saisir un numéro d'inventaire, correspondant ensuite au nom de l'ordinateur dans GLPI, d'éxecuter l'agent-glpi, monter un dossier partagé avec un serveur NFS afin d'y enregistrer les fichiers logs, éxecuter un test de mémoire vive, lancer l'effacement des disques ainsi qu'éxecuter un test rapide puis long des disques.

* ***smart.sh***
Créé par Meliorator (irc://irc.freenode.net/Meliorator) et amélioré par Ranpha, ce script permet de lister l'ensemble des stockages présents sur la machine et d'effectuer un test SMART short ou long suivant l'option choisie lors de son appel.

Merci à @M3GH4N pour sa contribution à la partie nfs et à tous les tests effectués.
