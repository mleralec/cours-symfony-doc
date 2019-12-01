# Projet (à rendre avant vendredi 06 décembre - 18h)

- [ ] Installation
- [ ] Ajout de produits
- [ ] Page /product et /product/{id}
- [ ] Ajout d'un produit dans le panier
- [ ] Page /panier
- [ ] Suppression d'un produit du panier
- [ ] Page d'accueil
- [ ] Entité Command
- [ ] Validation du panier
- [ ] Page /command et /command/{id}

---

#### 1 - Installation

Vous allez réaliser un POC sur une petite boutique e-commerce avec le Framework Symfony. Vous utilisez Docker pour créer votre environnement de développement. Ce projet aura 3 conteneurs :
- PHP
- MySQL
- PHPMyAdmin

Le conteneur PHP pointera sur le port 8888 de l'hôte.
Le conteneur PHPMyAdmin pointera sur le port 8889 de l'hôte.

Vous pouvez faire ce projet sur votre serveur ou votre machine personnelle, j'installerai votre environnement sur ma machine via votre repository GIT pour la correction.

Assurez vous que votre connexion à votre PHPMyAdmin fonctionne pour passer à l'étape suivante.

---

#### 2 - Ajout de produits

Créez une entité Product avec les champs suivants :

| Nom         | Type         | Nullable |
| ----------- | ------------ | -------- |
| name        | string (255) | no       |
| price       | integer      | no       |
| description | text         | no       |
| createdAt   | datetime     | no       |

Créez ensuite une fixture `ProductFixtures` dans laquelle vous allez créer une vingtaine de produits.  
Vous pouvez utiliser la méthode `randomNumber(2)` de *Faker* pour générer un prix.

---

#### 3 - Page /product et /product/{id}

Créez une page avec la route `/product` qui liste les différents produits disponible.  
Pour chaque produit, vous afficherez :
-   Son titre avec un lien vers la page `/product/{id}`
-   Son prix
-   Les 300 premiers caractères de la description suivi d'un `... voir plus`
-   Le **...voir plus** est également un lien vers `/product/{id}`
-   La date de création avec le format 24/12/2019

Créez également la page `/product/{id}` qui affiche toutes les informations d'un produit avec sa description complète. Vous ajouterez un lien *retour* sur cette page qui redirige vers la liste des produits.

Au niveau de vos vues, vous pouvez ajouter Bootstrap via un CDN ainsi qu'un menu qui comporte ces 4 liens :
- Accueil
- Produits
- Commandes
- Panier

---

#### 4 - Ajout d'un produit au panier

Créez une route `/panier/add/{id}` qui récupère l'id d'un produit à ajouter dans le panier. Pour stocker le panier d'un utilisateur, vous allez utiliser la session. Pour se faire, vous devez la récupérer depuis la `SessionInterface`. 

```php
public function add($id, SessionInterface $session)
{
    $panier = $session->get('panier', []);
    // ...
    $panier[$id] = 1;
    // ...
    $session->set('panier', $panier);
    // ...
}
```

Avec la méthode `get` sur la session, on récupère la valeur courante de "panier". Si celle-ci est nulle, on lui assigne un tableau vide.
Vous allez stocker le panier sous forme d'un tableau associatif avec comme clé l'id d'un produit et comme valeur sa quantité. Celle-ci sera toujours égale à 1 dans notre cas, car vous n'allez pas gérer de quantités dans ce projet.  

Sur la page de détail d'un produit, ajoutez un bouton "**Ajouter au panier**". Au clic sur ce bouton, vous allez faire une requête AJAX avec `fetch` sur votre route `/panier/add/{id}`. Cette route retourne une réponse en JSON avec soit un message "ok" avec un code 200, soit un message "nok" et un statut 404 si le produit n'existe pas.

Une fois que le produit est ajouté au panier, ajoutez la classe `disabled` sur le bouton et affichez une alerte pour informer l'utilisateur que le produit est bien ajouté au panier.

---

#### 5 - Page /panier

Créez une page avec la route `/panier`. Si le panier contient des produits, affichez un tableau avec 3 colonnes :
- Nom du produit
- Quantité
- Prix 

Vous affichez également le total du panier en € sur la dernière ligne du tableau.

> À ce stade le panier n'est qu'un tableau d'IDs et de quantités. Vous devez donc récupérez les produits du panier dans le Controller pour les redescendre à la vue.

```php
$products = [];
foreach($panier as $id => $quantity) {
    $products[] = // ...
```

---

#### 6 - Suppression d'un produit du panier

Sur la page panier, vous devez pouvoir supprimer un produit qui se trouve dans le panier.  
Ajoutez un bouton *Supprimer* à côté du nom du produit. En cliquant sur ce bouton, vous appellerez la route `/panier/delete/{id}` que vous devez créer.

Dans votre Controller, vous devez vérifier si le produit existe dans le panier, si oui, supprimez le. Vous re-dirigez ensuite l'utilisateur sur la page `/panier` avec une alerte flash pour l'informer que le produit a bien été supprimé du panier si c'est le cas.

---

#### 7 - Page d'accueil

Créez la page d'accueil qui manque à votre site.  
Sur cette page, vous afficherez deux colonnes. La première affiche les 5 produits les plus récents et la deuxième affiche les 5 produits les moins cher.

Pour la première colonne, vous affichez le nom du produit ainsi que sa date de création et pour la deuxième colonne, vous affichez son nom et son prix.

Tous ces produits doivent avoir un lien qui redirige vers la page de détail du produit.

---

#### 8 - Entité Command

Créez une entité Command avec les champs suivants :

| Nom         | Type         | Nullable |
| ----------- | ------------ | -------- |
| email       | string (255) | no       |
| products    | ManyToMany   | no       |
| createdAt   | datetime     | no       |

> Le champs **products** est relié à l'entité Product, à la question "Do you want to add a new property to Product so that you can access/update Command objects from it - e.g. $product->getCommands()", répondez non.
 
---

#### 9 - Validation du panier

Créez maintenant un formulaire `CommandType` qui sera lié à l'entité Command et que vous afficherez sur la page `/panier` pour valider la commande. Vous afficherez le formulaire sous le tableau des produits qui sont dans le panier.

Vous afficherez seulement le champ *email* dans ce formulaire, vous remplirez les autres champs (les produits et la date de création de la commande) à la soumission de ce formulaire.

> Symfony semble avoir déprécier le fait d'injecter l'ObjectManager directement dans un Controller, pour récupérer le manager depuis un Controller, vous pouvez utilisez :
```php
$manager = $this->getDoctrine()->getManager();
```

Vous pouvez ajoutez une règle de validation "email" sur le champ email de l'entité Command. Si le formulaire est soumis et validé, vous pouvez ajouter les produits du panier dans la commande et sauvegarder la commande en base de données. Vous pouvez également afficher une alerte "flash" et rediriger sur cette même page `/panier`. 

---

#### 10 - Page /command et /command/{id}

Créez une page avec la route `/command` qui liste toutes les commandes disponibles. Pour chaque commande, vous affichez l'id de la commande ainsi que l'adresse email de l'acheteur. Ces deux éléments sont englobés dans un lien vers la page `/command/{id}` que vous devez créer.

Sur cette page, vous affichez l'id d'une commande, l'email de l'acheteur ainsi que tous les produits (nom + prix) avec un lien vers la page `/product/{id}`. Vous afficherez également le nombre de produits et le prix total de la commande.

---

## Correction

Envoyez moi le lien de votre projet sur Git par mail (*mickael.leralec@gmail.com*) avant le **vendredi 06 décembre à 18h**. 

Le dossier *vendor* ne doit pas être poussé sur votre repository Git.

J'effectuerai les commandes suivantes pour installer votre projet :

```bash
git clone votre-projet.git
cd votre-projet
# ajout de mes variables d'environnement dans le fichier .env
composer install
docker-compose up -d
docker exec -it votre-container-php bash
php bin/console migrate
php bin/console doctrine:fixtures:load
```

Une fois ces commandes effectuées, votre site doit être accessible et votre base de données doit contenir des produits.