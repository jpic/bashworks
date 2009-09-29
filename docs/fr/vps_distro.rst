Tout casser
===========

Pour casser emerge dans un guest, il suffit de mettre des FEATURES dans /etc/make.conf du guest.

MEME si ce n'est QUE pour mettre "buildpkg", qui devrait n'avoir aucun rapport avec les permissions.
Workaround: EMERGE_DEFAULT_OPTS="-b"

VPS framework
=============

Intro
-----

Pour charger ou rafraichir le framework de VPS::

    jsource vps

Toutes les commandes et variables de ce framework ont le prefixe *vps_*.

Creer un VPS de test
--------------------

Example::

    liria ~ #i vps_create_config 43 testBar
    updating testBar.config
    VPS configuration set up, check and run vps_generate or DIY
    (vps:testBar) liria ~ # vps_generate
    [..snip..]
    (vps:testBar) liria ~ # vps_enter
    testbar ~ # 

Choisir le VPS
--------------

Pour informer le framework qu'on se concentre sur un serveur existant::

    vps_load_config vpsname # remplacer vpsname

On dispose ensuite de variables telles que:

- $vps_ip=192.168.1.123
- $vps_root=/vservers/machin
- etc ...

Ainsi que de fonctions telles que:

- vps_start,
- vps_stop,
- vps_delete,
- vps_restart

Certaines fonctions ne touchent pas forcement au vps courant, comme par exemple:

- vps_delete_test_vps qui efface tout les vps dont le nom commence par test.

Cote host
---------

Chaque VPS a un nom ainsi qu'un id. Gentoo utilise le nom dans 2 dossiers:

- /vservers contient les chroots,
- /etc/vservers contient les configs.

Et le framework utilise une config dans /etc/vservers/name.config. L'interet
est qu'on peut toucher les variables dans ce script, ou redefinir des
fonctions speciallement pour cette vps!

Notre script de creation utilise l'id pour configurer l'ip du vps, example::

- id = 2 donc ip = 192.168.1.2,
- id = X donc ip = 192.168.1.X,

Note: les clients qui payent prennent les id > 99.

Cote guest
----------

On emerge d'abord sur le vps "master" puis on deploie les binpkg de portage
dans les guests::

    vemerge master -- app-editors/vim -va
    vemerge myguest -- app-editors/vim -K # -K=binpkg

Le framework a quelques fonctions pour automatiser:

- vps_euse change les use de "master" pour un package specifique,
  example: vps_euse dev-db/mysql big-tables -berkdb
- vps_emerge: qui emerge d'abord sur "master" et si ca n'echoue pas emerge
  sur le guest en cours. Il est utilisable exactement comme la commande "emerge" de
  base, puisque le framework sais quelle vps est en cours d'administration.
- vps_backport: prend un package atom en argument, et l'ajoute dans
  /vservers/master/etc/portage/package.keywords

Deletion
========

On n'efface pas les versers de /vservers ni de /etc/vservers::

    vserver fooproject delete
    rm /etc/vservers/fooproject.config

Ou, avec le framework::
    
    vps_load_config fooproject
    vps_delete

Si il faut vraimment effacer un vserver a la main, commencer par /vservers et terminer par /etc/vservers,
en effaceant bien le fichier de conf.

Mises-a-jour
============

Le vserver "master" a l'id 2 est celui dans lequel on emerge avec la commande suivante par exemple::

    vemerge myguest -- app-editors/vim -vaK # pour emerger le binpkg, si il y en a un
    vemerge master -- app-editors/vim -va # pour compiler si il n'y a pas de binpkg
    vemerge myguest -- app-editors/vim -vaK # pour emerger le binpkg puisqu'on vient de le faire

Si c'est bon, on peut mettre a jour les autres VPS sans compiler::

    # mettra a jour le vserver "fooproject":
    vupdateworld fooproject -- -vp 
    vupdateworld fooproject -- -k

    # tous:
    vupdateworld --all -- -k

Pour aller plus vite, on peut avec mon framework::

    jsource vps
    vps_load_config $vps_name
    vps_emerge ... # ou "..." peut etre "-av vim" ou autre

La fonction vps_emerge essaye d'abord d'emerger le binpkg. Si il n'existe pas: il compile dans master
et emerge binpkg.

On peut utiliser un autre master en specifiant son nom dans $vps_master

HTTP
====

Le script est en cours de creation.

FastCGI
-------

Il s'agit de demons qui sont accessibles par un socket unix. Lighttpd doit avoir rwx sur le socket.

Lighttpd est chroote dans /vservers

FTP
---

Il va falloir une config speciale dirigee par une bdd.

Ca tournera sur le host.

MySQL/PostgreSQL
----------------

On le chroot dans les guest.

Mail
----

Une config speciale avec mysql et postfixadmin, dans le host.

SSH
---

Les VPS n'ecoutent pas a temps complet aux connections ssh qu'aucun client ne demande pour l'instant.

La connection au VPS en ssh passe par le flux suivant:

0) forward du port 22 du vps vers un port "haut" du host,
1) connection du client au vps par le forward,
2) deletion du forward.

Commandes::

    vps_load_config $vps_name # ou $vps_name peut etre "master"
    vps_ssh $port # ou $port est le port "haut" du host
