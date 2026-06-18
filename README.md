<div align="center">

# 📱 Hall-E — App Mobile 🍻🎮

### *Transformez vos soirées entre amis en expériences inoubliables.*

Trouvez en quelques clics les bars les plus animés qui diffusent
les parties de jeux vidéo les plus palpitantes près de chez vous.

![Platform](https://img.shields.io/badge/platform-iOS%20%7C%20Android-blue)
![Status](https://img.shields.io/badge/status-active-success)
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

> ℹ️ Les éléments entre `< >` sont à adapter à ton environnement.

### 🧱 Stack

- **React Native** *(à confirmer)*
- Consommation de l'**API Hall-E** via REST
- Gestion d'état : Redux / Zustand / Context *(à préciser)*

### ✅ Prérequis

- Node.js `>= 18` et `npm`
- Environnement React Native (Android Studio / Xcode)
- Une instance de l'**API Hall-E** accessible

### ⚙️ Installation

```bash
npm install
```

### 🔐 Configuration (.env)

| Variable       | Description                         | Exemple                 |
| -------------- | ----------------------------------- | ----------------------- |
| `API_BASE_URL` | URL de base de l'API Hall-E         | `http://localhost:3000` |
| `MAPS_API_KEY` | Clé de l'API de cartographie/géoloc | `<key>`                 |

### ▶️ Lancement

```bash
npm run android      # Android
npm run ios          # iOS
npm start            # Metro bundler
```

### 🗂️ Structure indicative

```
src/
├── screens/        # Écrans (recherche, détail bar, profil…)
├── components/     # Composants réutilisables
├── services/       # Appels à l'API Hall-E
├── store/          # Gestion d'état
└── App.tsx         # Point d'entrée
```

### 🧪 Tests

```bash
npm test
```

---

<div align="center">

🔗 **Projets liés** — [API](./README-api.md) · [Service de récupération](./README-recuperation.md) · [Package BDD](./README-bdd.md)

</div>