# StencilCompilateur

## À propros

Ce projet a été réalisé dans le cadre du cours de Compilation de la quatrième année du _Cursus Master en Ingérie_ spécialisé en Informatique, systèmes et réseaux, à _l'Université de Strasbourg_.
Le but de ce projet était de réaliser un compilateur pour le langage Stenc.

## Spécificité du langage Stenc

Le langage Stenc est basé sur le langage C. Il s'agit d'un sous-ensemble du langage C auquel a été ajouté un type stencil, un opérateur d'application de stencil, ainsi que les restrictions suivantes :
* Le seul type possible est int (constante possible)
* Les tableaux tableaux multidimensionnels de int sont possibles
* Les opérateurs possibles sont +, - (unaire et binaire), \*, \/, ++ et --
* Les structures de controles possibles sont if (avec ou sans else), while et for
* Les appels de fonction (y compris récursivement) sont possibles
* Les fonctions de bases sont _printf()_ qui affiche une chaîne de caractères, et _printi()_, qui affiche un entier

## Implémentation

### Déclaration

* entiers
    * int i;
    * [const] int i = number;
    * [const] int i = id;
    * [const] int i = expression
* tableaux :
    * int tab[number];
    * int tab[id];
    * int tab[x] = {...}; n'a pas été implémenté

Il n'est pas possible de modifier une constante (erreur compilation), et l'utilisation d'une variable non initialisée génère un warning à la compilation. Une re-déclaration d'une variable provoque une erreur à la compilation.

Les tableaux peuvent être multidimensionnels. Un tableau déclaré avec une valeur qui n'est pas une constante provoque une erreur à la compilation.

Il est possible de déclarer des constantes globales grâce à la directive de préprocesseur _#define_.

### Expressions arithmétiques

Les opérateurs possibles pour les expressions sont les suivants :
* +, ++
* -, --
* \*,
* \/
* =

L'opérateur _-_ peut être unaire.

Les parenthèses pour donner des priorités à certaines expressions sont également possibles.

L'accès au tableau par des expressions, par exemple _tab[i+2]_ est possible.

### Structures de contrôles

Les structures de contrôles sont possible, y compris imbriquées.
Sont disponibles :
* if, if/else
* while
* for

Cependant, _else if_ n'a pas été implémenté.

Les conditions sont des opérations booléennes, avec les opérateurs suivants :
* ==
* !=
* <, <=
* \>, >=
* &&
* ||
* !
* true
* false

Les parenthèses pour donner des priorités à certaines conditions sont également possibles.

### Fonctions d'affichage

Les fonctions printi et printf ont été implémentées. Il est donc possible d'afficher une chaine de caracètres ASCII grâce à la fonction _printf()_, et un entier grâce à la fonction _printi()_.

La fonction _printi()_ en paramètre une variable _id_ ou un nombre _number_, ou une expression arithmétique.

### Fonctions

Les appels de fonctions personnelles n'ont pas été implémentés. La seule fonctions présente dans le code doit être la fonction _main()_, avec la structure suivante :

    int main(){
        //code
        return number;
    }

_number_ peut être un nombre, une variable, ou une expression arithmétique.
Le _return_ est imporant. S'il est absent, cela provoque une erreur à la compilation.

### Commentaires

Il est possible d'utiliser des commentaires. Deux sortes de commentaires sont ignorés par le compilateur :
* Sur une seule ligne
* Multi-lignes

Comme en C, les commentaires sur une seule ligne sont de la forme `//Ceci est un commentaire`, et les commentaires sur plusieurs lignes sont de la forme

    /*
    Ceci est
    commentaire
    sur plusieurs
    lignes.
    */

## Auteurs

* [Jean-Philippe Abegg](https://github.com/MrSaTurNin) - [contact](mailto:jean-philippe.abegg@etu.unistra.fr)
* [Lucas Pierrat](https://github.com/iAmoric) - [contact](mailto:lucas.pierrat@etu.unistra.fr)
