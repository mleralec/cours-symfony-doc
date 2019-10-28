# TP 1

-   [ ] Notre première page
-   [ ] Introduction à Twig
-   [ ] Créer des données
-   [ ] Utilisons ces données
-   [ ] Affichage d'une page article
-   [ ] Ajout d'un champ slug

---

### Notre première page

Créez un Controller `ArticleController` à l'aide de la commande `php bin/console make:controller`.

Cette commande crée également :

-   une route définie dans le Controller (`src/Controller/ArticleController`)
-   une vue dans le dossier `templates/article/index.html.twig`.

On constate que la route est définie sous forme d'annotations directement au-dessus de la méthode. Il existe plusieurs méthodes pour créer des routes sur Symfony (yaml, xml, annotations...). Nous resterons sur le système d'annotations dans ce cours.

Modifiez cette route pour changer le nom par `article.index`.

> **Comment Symfony sait-il ou chercher les routes ?**  
> C'est dans le fichier `config/routes/annotations.yaml` qu'on demande à Symfony de rechercher toutes les routes sous formes d'annotations dans le répertoire `src/Controller`.

Disséquons maintenant le code de la méthode `index` du Controller:

```php
public function index()
{
    return $this->render('article/index.html.twig', [
        'controller_name' => 'ArticleController',
    ]);
}
```

Ici, la méthode `render` qui nous permet de renvoyer une vue. Par défaut, Symfony va chercher les vues dans le dossier `templates` (voir la configuration dans `config/packages/twig.yaml`).
Nous chargeons donc ici la vue par défaut, à savoir celle qui a été créée avec ce Controller.  
Le deuxième paramètre de la fonction `render` est un tableau de variables qu'on passe directement à la vue.

Vous l'avez sûrement remarqué, nous utilisons `$this` pour récupérer la méthode `render`. En effet, notre Controller étend la classe `AbstractController` qui utilise le Trait `ControllerTrait`. Vous pouvez regarder dans ces différents fichiers les méthodes misent à disposition dans notre Controller.

Rendez-vous sur `***.lpweb-lannion.fr:7777/article` pour découvrir votre première page créée avec Symfony.

---

### Introduction à Twig

Twig est un moteur de template qui permet d'écrire nos vues très simplement avec une syntaxe plus légère et moins verbeuse que du PHP. Voir la [documentation de Twig](https://twig.symfony.com/)

Jettons un oeil à notre vue dans `templates/article/index.html.twig`.
La première ligne permet d'étendre d'un gabarit pré-défini.  
Ce layout nous permet de définir des sections globales au site pour ne pas à avoir à les dupliquer (head, menu, footer...)

Il suffit de définir des `block` via `{% block body %}{% endblock %}` dans le layout et je pourrai ensuite l'utiliser dans ma vue de la même manière.

Tout le code que j'inclurai dans un block sera intégré au block du layout.

Nous constatons que dans la vue on affiche `{{ controller_name }}`, c'est une variable qui vient directement du Controlleur, vous pouvez changer sa valeur dans notre Controller et rechargez la page.

Twig utilise la syntaxe `{{ }}` pour afficher quelque chose et `{% %}` pour utiliser une fonction du langage.

Exemple:

```html
<main>
    {% if users | length > 0 %}
        <section class="user">
            {% for user in users %}
            <div class="card-user">
                <h3>{{ user.name | upper }}</h3>
                <p>{{ user.description }}</p>
            </div>
    
            {% endfor %}
        </section>
    {% else %}
        <p>No users have been found...</p>
    {% endif %}
</main>
```

Vous pouvez inclure Bootstrap dans le fichier `base.html.twig` via un CDN.

Ajoutez un fichier `templates/partials/_nav.html.twig` et ajouter un menu avec 3 liens :
- **Accueil** sur "/"
- **Article** sur "/article"
- **Catégorie** sur "/category"

Importez ce fichier `_nav.html.twig` dans le fichier `base.html.twig` avec la fonction `include` de Twig :
```php
{% include "partials/_nav.html.twig" %}
```

---

### Créer des données

Jusqu'ici nous avons parlé du Controlleur et de la Vue, il manque donc la partie Model (la liaison entre notre application et la base de données).  
Dans Symfony, une entité représente une table. Nous allons commencer par créer une entité **Article**, qui possèdera les champs suivants :

| Nom       | Type         | Nullable |
| --------- | ------------ | -------- |
| title     | string (255) | no       |
| author    | string (255) | no       |
| content   | text         | no       |
| createdAt | datetime     | no       |

Pour créer une entité, utilisez la console :

```
php bin/console make:entity
```

Deux nouveaux fichiers sont ensuite créés :

-   src/Entity/Article
-   src/Repository/ArticleRepository

Le premier représente la table sous forme d'une classe avec ses getters/setters, on remarque d'ailleurs que Symfony a généré tout le code pour nous.  
Le deuxième fichier représente le "repository", c'est-à-dire le fichier de sélection, c'est la qu'on écrira nos requêtes pour attaquer la base de données.

> Symfony fait le choix de séparer la classe du repository, c'est pratique pour s'y retrouver, surtout sûr de gros projets. D'autres Frameworks font tout directement dans le Model, c'est le cas de Laravel par exemple.

La commande `make:entity` ne fait que créer des fichiers dans notre projet Symfony, pour modifier la structure de notre base de données, il faut effectuer `make:migration`.  
Cette commande demande à Symfony de vérifier les différences qu'il existe entre notre structure SQL actuelle et nos fichiers dans le répertoire `src/Entity`. Symfony va ensuite générer un fichier contenant des instructions SQL si celui-ci détecte des différences.

La commande génère ensuite un fichier dans le répertoire `src/Migrations`, la fonction `up` ajoute les nouveautés depuis la dernière migration alors que la fonction `down` annule cette migration.
Il faut maintenant lancer la commande `doctrine:migrations:migrate` pour appliquer la fonction `up` de la migration.

Il ne reste plus qu'à vérifier dans PhpMyAdmin que la table Article a bien été ajoutée.

> Ce système de migrations est très performant et utilisé par l'ensemble des Frameworks modernes. Celui-ci permet de récupérer le projet via git par exemple, il suffit ensuite de lancer la commande `doctrine:migrations:migrate` pour effectuer toutes les migrations du projet et avoir la structure de la base de données à jour avec le projet.

Nous allons maintenant utiliser une librairie qui nous permet de remplir notre table avec une commande Symfony plutôt que d'avoir à créer les articles directement dans PhpMyAdmin. Pour cela nous avons besoin de [orm-fixtures](https://packagist.org/packages/doctrine/doctrine-fixtures-bundle). Nous allons également utiliser une librairie pour générer des données "fake" à notre place, il s'agit de [Faker](https://packagist.org/packages/fzaninotto/faker)

Comme nous travaillons avec Docker et que composer n'est pas installé sur le serveur, nous allons créer un conteneur temporaire avec l'image Composer pour ajouter nos 2 dépendances :

```bash
docker run --rm --interactive --tty \
  --volume $PWD:/app \
  --user $(id -u):$(id -g) \
  composer require orm-fixtures fzaninotto/faker --dev
```

On rajoute ici le `--dev` car ces dépendances ne seront pas utilisées en production.

Nous pouvons maintenant créer notre Fixture `ArticleFixtures` à l'aide de la commande `make:fixtures`. Voilà à quoi ressemble mon fichier :

```php
public function load(ObjectManager $manager)
{
    $faker = Factory::create();

    for ($i = 1; $i <= 10; $i++) {
        $article = new Article();

        $title = substr($sentence, 0, strlen($sentence) - 1);
        $article->setTitle($title)
                ->setAuthor($faker->name)
                ->setContent($faker->text(500))
                ->setCreatedAt($faker->dateTimeThisYear());

        $manager->persist($article);
    }

    $manager->flush();
}
```

Je commence par récupérer l'objet Factory de Faker. Je crée ensuite 10 articles dans une simple boucle `for`, à l'intérieur de celle-ci je crée un nouvel Article, j'appelle ensuite ses différents "setters" qui sont définis dans sa classe.
J'utilise ensuite les méthodes de Faker pour me générer des données pertinentes. Voir la [documentation de Faker](https://github.com/fzaninotto/Faker).

Le manager est fourni par l'ORM **doctrine** et celui-ci me permet de persister un article à chaque tour de ma boucle. Je finis par utiliser la fonction `flush`, pour sauvegarder en base de données tout ce qui était stocké dans mon manager (via la commande **persist**).

Pour exécuter cette Fixture, entrez la commande suivante :

```
php bin/console doctrine:fixtures:load
```

Ouvrez ensuite votre PhpMyAdmin pour découvrir les données que nous venons de générer.

---

### Utilisons ces données avec doctrine

Pour utiliser les données d'une entité, nous avons besoin de son Repository.

```php
$articleRepository = $this->getDoctrine()->getRepository(Article::class);
```

Nous avons maintenant accès au Repository de la classe Article, pour rappel, celui-ci se trouve dans `src/Repository/ArticleRepository`, nous pouvons voir toutes les méthodes disponibles. Par défaut, aucune méthode n'est disponible. Si on regarde plus en profondeur dans le code, nous pouvons voir que notre Repository étends de la classe `EntityRepository` dans le dossier `/vendor/doctrine/orm/lib/Doctrine/ORM/`.  
Nous pouvons voir que beaucoup de méthodes sont définies pour nous.

Commençons par récupérer tous les articles :

```php
$articles = $articleRepository->findAll();
```

Pour constater les données que nous récupérons dans `$articles`, nous pouvons utiliser la fonction `dd` de Symfony, qui permet de faire un `dump`, une version améliorée du `var_dump` de PHP suivi d'un `die`.

```php
public function index()
{
    ...
    $articles = $articleRepository->findAll();
    dd($articles);
    ...
}
```


Symfony nous aide encore une fois et nous propose une autre syntaxe plus simple à écrire qui consiste à bénéficier de l'injection de dépendances de Symfony en récupérant le Repository directement en paramètre de la méthode. En effet, en précisant le type qui est attendu dans la variable, Symfony sait ce qu'il doit nous retourner :

```php
public function index(ArticleRepository $articleRepository)
{
    $articles = $articleRepository->findAll();
    ...
```

Nous pouvons ensuite renvoyer la variable `$articles` à notre vue, comme l'exemple `controller_name`.
Utilisez Twig pour afficher ensuite la liste des articles dans votre vue.

Pour chaque article :
-   afficher son titre avec un lien vers `/articles/{id de l'article}`
-   afficher les 300 premiers caractères du contenu suvivi d'un `... voir plus` (filtre slice)
-   le **...voir plus** est également un lien vers `/articles/{id de l'article}`
-   afficher la date avec un format 24/12/2019 ainsi que le nom de l'auteur

---

### Affichage d'une page article

Commencer par créer une nouvelle méthode `show` dans votre `ArticleController` qui prend en paramètre l'id de l'article avec la route suivante : `@Route("/article/{id}", name="article.show")`

Récupérez l'article associé à l'id reçu via la fonction `find` du Repository. Cette fonction prend par défaut l'id de l'article. Retournez ensuite l'article à la vue `templates/article/show.html.twig`.

Si aucun article n'est trouvé avec l'id passé en paramètre, renvoyez une page 404 :
```php
if (!$article) {
    throw $this->createNotFoundException('The article does not exist');
}
```

Cette nouvelle vue doit étendre du template `base.html.twig`, vous afficherez : le titre de l'article, son contenu, son titre et sa date de création avec le format 24/12/2019. Ajoutez également un lieu **retour** qui permet de retourner à la liste des articles.

Profitez-en pour modifier les liens dans notre template `index.html.twig` avec la fonction `path` de Twig plutôt que d'avoir des liens en dur. 
`<a href="{{ path('article.show', {'id' : article.id}) }}">`
Cette méthode permet de changer les urls des routes sans avoir à modifier toutes les urls dans notre code.

---

### Ajout d'un champ slug

Actuellement, nos urls ne sont pas très jolies : `mon-site/article/1`, en général, on affiche un slug équivalent au titre de l'article : `Titre de mon 1er Article` = `titre-de-mon-1er-article`.

Modifiez ensuite l'entité `Article` pour ajouter un champ `slug` ainsi que son getter/setter.
On effectue ensuite la commande `make:migration` pour que Symfony détecte le changement de la structure et génère un fichier de migration.
Regardez ce nouveau fichier de migration et si il vous semble convenable, utilisez la commande `doctrine:migrations:migrate`.

Vous pouvez vérifier la nouvelle structure dans PHPMyAdmin. Dans notre fichier `src/DataFixtures/ArticleFixtures` nous devons maintenant mettre à jour la génération de nos articles avec ce nouveau champ `slug`.

Mettez à jour le fichier `ArticleFixtures` en rajoutant le slug. Faker possède déjà une fonction slug pour nous :
```php
$article
    ->setTitle($title)
    ->setSlug($faker->slug())
```

Générez ensuite de nouveaux articles avec la commande `doctrine:fixtures:load`, vérifiez ensuite dans PHPMyAdmin que le titre de l'article correspond bien à son slug.

Replacez la route `article.show` avec le slug `@Route("/article/{slug}", name="article.show")`. 
Vous pouvez ensuite récupérer l'article via `$repository->findOneBy(['slug' => $slug]);`.

Il ne reste plus qu'à modifier les liens sur le template `article/index.html.twig` avec le slug et vérifier que tout fonctionne à nouveau.
