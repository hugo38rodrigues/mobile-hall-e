<div align="center">

# 📱 Hall-E — App Mobile 🍻🎮

### *Transformez vos soirées entre amis en expériences inoubliables.*

Trouvez en quelques clics les bars les plus animés qui diffusent
les parties de jeux vidéo les plus palpitantes près de chez vous.

![Platform](https://img.shields.io/badge/platform-iOS%20%7C%20Android-blue)
![Flutter](https://img.shields.io/badge/flutter-%3E%3D3.0-02569B?logo=flutter)
![Status](https://img.shields.io/badge/status-beta)
![Made with](https://img.shields.io/badge/made%20with-❤️%20%26%20🎮-red)

</div>

---

## 🎉 Présentation

**Hall-E Mobile** est l'application qui accompagne les fêtards : elle leur permet de
**localiser les bars qui diffusent des matchs de jeux vidéo**, de **réunir leurs amis**
et de **profiter des parties** tout en dégustant leurs boissons préférées.

### ✨ Fonctionnalités

- 🔍 **Trouvez le bar parfait** — recherche géolocalisée des bars diffusant des matchs.
- 👯‍♂️ **Réunissez vos amis** — organisez et planifiez vos soirées.
- 🎮 **Suivez les parties** — consultez les diffusions en cours et à venir.
- ⭐ **Vos favoris** — retrouvez vos bars préférés en un instant.

### 🚀 Comment ça marche ?

1. **Inscrivez-vous** — créez votre compte en quelques étapes.
2. **Explorez** — recherchez les bars près de chez vous.
3. **Planifiez** — choisissez un bar, invitez vos amis, et c'est parti !

---

## 🛠️ Partie Dev

### 🧱 Stack

- **Flutter** (Dart)
- Consommation de l'**API Hall-E** via REST (`http` / `dio`)
- Gestion d'état : Provider / Riverpod / Bloc *(à préciser)*
- Géolocalisation : `geolocator` + `google_maps_flutter` *(à préciser)*

### ✅ Prérequis

- **Flutter SDK** `>= 3.0` ([guide d'installation](https://docs.flutter.dev/get-started/install))
- **Dart SDK** (inclus avec Flutter)
- Un IDE configuré (Android Studio / VS Code + plugins Flutter & Dart)
- Un émulateur Android ou un simulateur iOS, ou un appareil physique
- Une instance de l'**API Hall-E** accessible

Vérifiez votre installation avec :

```bash
flutter doctor
```

### ⚙️ Installation

```bash
flutter pub get
```

### 🔐 Configuration (.env)

Le projet utilise [`flutter_dotenv`](https://pub.dev/packages/flutter_dotenv) pour la gestion des variables d'environnement.

| Variable       | Description                         | Exemple                 |
| -------------- | ------------------------------------ | ----------------------- |
| `API_BASE_URL` | URL de base de l'API Hall-E          | `http://localhost:3000` |
| `MAPS_API_KEY` | Clé de l'API de cartographie/géoloc  | `<key>`                 |

Créez un fichier `.env` à la racine du projet et pensez à le déclarer dans `pubspec.yaml` :

```yaml
flutter:
  assets:
    - .env
```

### ▶️ Lancement

```bash
flutter run                      # Lance sur l'appareil/émulateur connecté
flutter run -d android           # Force Android
flutter run -d ios               # Force iOS
flutter devices                  # Liste les appareils disponibles
```

### 📦 Build

```bash
flutter build apk                # Android (APK)
flutter build appbundle          # Android (App Bundle, pour le Play Store)
flutter build ios                # iOS (nécessite macOS + Xcode)
```

### 🗂️ Structure indicative

```
lib/
├── screens/        # Écrans (recherche, détail bar, profil…)
├── widgets/        # Composants réutilisables
├── services/        # Appels à l'API Hall-E
├── models/          # Modèles de données
├── providers/        # Gestion d'état (Provider/Riverpod/Bloc)
├── utils/           # Fonctions utilitaires, constantes
└── main.dart        # Point d'entrée

assets/
├── images/
└── icons/
```

### 🧪 Tests

```bash
flutter test                     # Tests unitaires et widgets
flutter test integration_test/   # Tests d'intégration
```

### 🧹 Analyse statique / Lint

```bash
flutter analyze
dart format .
```

---

<div align="center">

🔗 **Projets liés** — [API](./README-api.md) · [Service de récupération](./README-recuperation.md) · [Package BDD](./README-bdd.md)

</div>
