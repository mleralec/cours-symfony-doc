# Introduction

- [ ] Présentation de Symfony
- [ ] Installation

---

### Préambule

Ce cours se déroule en autonomie à l'aide des différents TPs qui sont à votre disposition, l'idée est que chacun avance à son rythme et en apprenne le maximum de son côté. N'hésitez pas à regarder la [documentation de Symfony](https://symfony.com/doc), c'est un réflexe important à avoir en tant que développeur. Si vous êtes bloqué ou si vous ne comprenez pas quelque chose, n'hésitez pas à m'appeler.

Dans les différents TPs, nous allons construire un blog pour parcourir les différentes fonctionnalités de Symfony.

---

### Présentation de Symfony

Symfony est un des Frameworks PHP les plus utilisés à l'heure actuelle avec Laravel. 
Il est organisé sous forme de composants qui peuvent être utilisés séparément, mais qui mit ensemble forment un Framework très puissant.

En effet, Symfony dispose de tout ce dont un développeur à besoin pour créer un site professionnel : ORM, moteur de Template, gestion des traductions, du cache, des Assets, Form Builder, client de test...

Comme exemple de sites développé avec Symfony, on peut citer Spotify, Blablacar et Openclassrooms mais également des CMS comme Drupal et Prestashop.
On retrouve également des composants de Symfony utilisés dans différents projets PHP : Laravel, PHPMyAdmin, Composer...

Les principaux avantages de Symfony sont :
- Grosse communautée
- Très simple à utiliser
- Documentation très fournie
- Made in France ! (compétence recherchée en France)

Symfony utilise la Programation Orienté Objet (éritage, namespaces, autoloading, injection de dépendances...etc.) Si vous n'êtes pas familier avec ces termes, je vous conseille de jeter un oeil à cette [formation sur la POO en PHP](https://www.grafikart.fr/formations/programmation-objet-php).  
Symfony utilise également le pattern MVC (Model-Vue-Controller) pour organiser le code. Ce Design Pattern est utilisé dans la majorité des Frameworks modernes, si cela ne vous dit rien, vous pouvez regarder [ce cours](https://openclassrooms.com/fr/courses/4670706-adoptez-une-architecture-mvc-en-php).

Symfony utilise également Composer pour gérer ses dépendances.
Composer est un gestionnaire de dépendances pour PHP, (comme NPM pour NodeJS ou PIP pour Python). Il est utilisé dans la majorité des projets PHP et par l'ensemble des Frameworks.
Les dépendances installées par Composer sont incluses dans le dossier `vendor` à la racine du projet et sont listées dans le fichier `composer.json`, lui aussi à la racine de votre projet.
Pour découvrir les différents projets disponible avec Composer, vous pouvez visiter le site [Packagist](https://packagist.org/).
Nous utiliserons Composer via Docker dans ce cours, vous n'avez donc pas besoin de l'installer sur votre serveur.

---

## Installation

Nous allons utiliser Docker dans ce cours pour installer nos différents services (PHP, MySQL, PHPMyAdmin).   
Commençons par créer un projet Symfony à l'aide de Composer. (Nous utilisons une image Docker de Composer pour ne pas à avoir à installer composer sur notre serveur. Pour plus d'informations sur l'image Docker de Composer, rendez-vous sur [la documentation de l'image.](https://hub.docker.com/_/composer/))

```bash
docker run --rm --interactive --tty \
  --volume $PWD:/app \
  --user $(id -u):$(id -g) \
  composer create-project symfony/website-skeleton cours-symfony --prefer-dist v4.3.*
```

Nous utilisons ici la commande [create-project](https://getcomposer.org/doc/03-cli.md#create-project) de Composer qui prend en premier argument le `vendor/project`, dans notre cas [symfony/website-skeleton](https://packagist.org/packages/symfony/website-skeleton) puis en deuxième paramètre le nom du répertoire à créer sur votre machine. Nous passons en paramètre la version 4.3.* pour que nous soyons tous sur la même version.


Récupérez les fichiers `Dockerfile` et `docker-compose.yml` et placez les à la racine de votre projet.

```bash
curl https://gitlab.com/mleralec/cours-symfony/Dockerfile > Dockerfile
curl https://gitlab.com/mleralec/cours-symfony/docker-compose.yml > docker-compose.yml
```

Si vous regardez le contenu du `docker-compose.yml`, vous pouvez voir qu'on appelle des variables d'environnement pour la connexion à la base de données :
```yml
env_file:
  - .env
environment:
  - MYSQL_DATABASE=${MYSQL_DATABASE}
  - MYSQL_USER=${MYSQL_USER}
  - MYSQL_PASSWORD=${MYSQL_PASSWORD}
```

Ici, nous demandons à Docker de récupérer les variables d'environnement présentent dans le fichier `.env` à la racine de notre projet. Symfony utilise également ce système de fichier "DotEnv" pour définir les variables d'environnement d'un projet. Vous devez donc définir ces différentes variables dans votre fichier `.env` sinon Docker remontera une erreur.

Vous devez également remplacer la ligne qui commence par `DATABASE_URL=...` avec la ligne suivante pour utiliser les variables d'environnement que vous venez de définir : 
-   `DATABASE_URL=mysql://${MYSQL_USER}:${MYSQL_PASSWORD}@mysql:3306/${MYSQL_DATABASE}`

Vous pouvez ensuite lancer vos conteneurs via docker-compose : `docker-compose up -d`

Testez ensuite d'accéder à votre site via `***.lpweb-lannion.fr:7777`.  
Essayez ensuite de vous connectez à votre PhpMyAdmin avec vos identifiants. Si la connexion fonctionne, vous pouvez passer au TP 1.

---


> Comme votre projet est sur votre serveur, vous pouvez utiliser [SSHFS](https://doc.ubuntu-fr.org/sshfs) pour accéder au système de fichier de votre serveur directement sur votre machine.

> Je vous conseille d'utiliser une extension PHP sur votre éditeur pour importer automatiquement les Namespaces. Pour VSCode, il existe [PHP Namespace Resolver](https://marketplace.visualstudio.com/items?itemName=MehediDracula.php-namespace-resolver).