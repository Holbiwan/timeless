# Guide de Navigation - Boutons de Retour Universels

## Vue d'ensemble

Le système de navigation Timeless propose plusieurs composants de retour avec un design uniforme :
- **Bordure orange/dorée** (ColorRes.darkGold)
- **Fond blanc** (ColorRes.white)
- **Icône noire** (ColorRes.black)

## Composants disponibles

### 1. Bouton de retour basique (`backButton`)

```dart
import 'package:timeless/common/widgets/back_button.dart';

// Usage simple
backButton()

// Avec action personnalisée
backButton(onTap: () {
  // Action personnalisée
  Get.offAllNamed('/home');
})
```

### 2. Bouton de retour universel (`universalBackButton`)

```dart
// Bouton icône simple
universalBackButton()

// Bouton avec texte
universalBackButton(
  showText: true,
  text: 'Retour',
)

// Avec action personnalisée
universalBackButton(
  onTap: () => Get.back(),
  showText: true,
  text: 'Accueil',
)
```

### 3. AppBar universel (`UniversalAppBar`)

```dart
import 'package:timeless/common/widgets/universal_app_bar.dart';

Scaffold(
  appBar: UniversalAppBar(
    title: 'Mon Écran',
    showBackButton: true, // true par défaut
    onBackPressed: () {
      // Action personnalisée si nécessaire
    },
    actions: [
      IconButton(
        icon: Icon(Icons.settings),
        onPressed: () {},
      ),
    ],
  ),
  body: // Votre contenu
)
```

### 4. Scaffold Timeless complet (`TimelessScaffold`)

```dart
import 'package:timeless/common/widgets/universal_app_bar.dart';

TimelessScaffold(
  title: 'Mon Écran',
  showBackButton: true,
  body: // Votre contenu
  actions: [
    IconButton(
      icon: Icon(Icons.search),
      onPressed: () {},
    ),
  ],
)
```

### 5. FAB de retour (`UniversalBackFab`)

```dart
import 'package:timeless/common/widgets/universal_back_fab.dart';

Scaffold(
  body: // Votre contenu
  floatingActionButton: UniversalBackFab(
    tooltip: 'Retour',
    mini: false,
  ),
)
```

### 6. Overlay de retour (`BackButtonOverlay`)

Pour les écrans fullscreen ou avec contenu personnalisé :

```dart
import 'package:timeless/common/widgets/universal_back_fab.dart';

Stack(
  children: [
    // Votre contenu fullscreen
    MyFullscreenContent(),
    
    // Bouton de retour en overlay
    BackButtonOverlay(
      alignment: Alignment.topLeft,
      margin: EdgeInsets.all(16),
    ),
  ],
)
```

## Logique de navigation intelligente

Tous les composants incluent une logique intelligente :

1. **Si possible**, retour à l'écran précédent (`Get.canPop()` → `Get.back()`)
2. **Sinon**, redirection vers le dashboard (`Get.offAllNamed('/dashboard')`)

## Exemples d'utilisation

### Écran de détail simple

```dart
class ProductDetailScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TimelessScaffold(
      title: 'Détail du produit',
      body: ProductDetailContent(),
    );
  }
}
```

### Écran sans AppBar avec FAB

```dart
class FullscreenImageScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FullscreenImageViewer(),
      floatingActionButton: UniversalBackFab(),
      floatingActionButtonLocation: FloatingActionButtonLocation.topLeft,
    );
  }
}
```

### Écran avec navigation personnalisée

```dart
class CustomNavigationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TimelessScaffold(
      title: 'Écran personnalisé',
      onBackPressed: () {
        // Demander confirmation avant de quitter
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Quitter ?'),
            content: Text('Voulez-vous vraiment quitter ?'),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: Text('Annuler'),
              ),
              TextButton(
                onPressed: () {
                  Get.back(); // Ferme la dialog
                  Get.back(); // Retour à l'écran précédent
                },
                child: Text('Quitter'),
              ),
            ],
          ),
        );
      },
      body: CustomContent(),
    );
  }
}
```

## Design système

Les boutons respectent la charte graphique Timeless :

- **Couleur de bordure** : `ColorRes.darkGold` (#D97706)
- **Couleur de fond** : `ColorRes.white` (#FFFFFF)
- **Couleur d'icône/texte** : `ColorRes.black` (#000000)
- **Ombrage** : Subtil avec la couleur dorée
- **Rayon de bordure** : 8px
- **Taille d'icône** : 18px (boutons normaux), 20px (overlay)