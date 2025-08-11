# Tasks Manager - Application To-Do Full-Stack

Une application de gestion de tâches moderne construite avec Laravel, Vue.js, Docker, et une architecture de composants atomiques avec Shadcn/ui.

## 🚀 Technologies Utilisées

### Backend
- **Laravel 10** - Framework PHP
- **MySQL** - Base de données
- **Redis** - Cache et sessions
- **JWT** - Authentification
- **Laravel Echo** - Notifications en temps réel
- **Pusher** - Service de WebSockets

### Frontend
- **Vue.js 3** - Framework JavaScript
- **Vite** - Build tool
- **Tailwind CSS** - Framework CSS
- **Shadcn/ui** - Composants UI
- **Pinia** - Gestion d'état
- **Vue Router** - Routing
- **Vue Toastification** - Notifications

### Infrastructure
- **Docker** - Conteneurisation
- **Docker Compose** - Orchestration
- **Nginx** - Serveur web
- **Supervisor** - Gestion des processus

## 🏗️ Architecture des Composants

Ce projet utilise l'**architecture de design atomique** combinée avec **Shadcn/ui** pour créer une interface utilisateur cohérente et maintenable.

### Structure des Composants

```
src/components/
├── atoms/           # 🧪 Composants de base
│   ├── BaseButton.vue
│   ├── BaseInput.vue
│   ├── BaseCard.vue
│   ├── BaseBadge.vue
│   ├── BaseModal.vue
│   ├── BaseSpinner.vue
│   └── BaseAlert.vue
├── molecules/       # 🧬 Composants composés
│   ├── FormField.vue
│   ├── TaskCard.vue
│   └── LoginForm.vue
├── organisms/       # 🦠 Composants complexes
│   ├── TaskList.vue
│   └── TaskForm.vue
└── ui/             # 🎨 Styles Shadcn
    ├── button.js
    └── input.js
```

### Avantages de l'Architecture Atomique

- **Réutilisabilité** - Composants modulaires et réutilisables
- **Maintenabilité** - Code organisé et facile à maintenir
- **Cohérence** - Design system uniforme
- **Évolutivité** - Facile d'ajouter de nouveaux composants
- **Performance** - Composants optimisés et légers

## 📦 Installation et Démarrage

### Prérequis
- Docker et Docker Compose
- Git

### 1. Cloner le projet
```bash
git clone <repository-url>
cd TasksManager
```

### 2. Lancer l'application
```bash
chmod +x start.sh
./start.sh
```

Le script `start.sh` va :
- Construire et démarrer tous les conteneurs
- Installer les dépendances
- Exécuter les migrations
- Générer les clés d'application

### 3. Accéder à l'application
- **Frontend** : http://localhost:3000
- **Backend API** : http://localhost:8000
- **Page de démonstration des composants** : http://localhost:3000/components

## 🎨 Utilisation des Composants

### Import des composants
```javascript
// Import individuel
import BaseButton from '@/components/atoms/BaseButton.vue'
import TaskList from '@/components/organisms/TaskList.vue'

// Import depuis l'index
import { BaseButton, TaskList } from '@/components'
```

### Exemple d'utilisation
```vue
<template>
  <BaseCard>
    <template #header>
      <h2>Titre de la carte</h2>
    </template>
    
    <div class="space-y-4">
      <FormField label="Nom" required>
        <BaseInput
          v-model="name"
          placeholder="Votre nom"
          :error="errors.name"
        />
      </FormField>
      
      <BaseButton
        variant="default"
        size="lg"
        :loading="loading"
        @click="handleSubmit"
      >
        Soumettre
      </BaseButton>
    </div>
  </BaseCard>
</template>
```

## 🔧 Configuration

### Variables d'environnement

#### Backend (.env)
```env
DB_CONNECTION=mysql
DB_HOST=mysql
DB_PORT=3306
DB_DATABASE=tasks_manager
DB_USERNAME=root
DB_PASSWORD=password

REDIS_HOST=redis
REDIS_PASSWORD=null
REDIS_PORT=6379

PUSHER_APP_ID=your_app_id
PUSHER_APP_KEY=your_app_key
PUSHER_APP_SECRET=your_app_secret
PUSHER_HOST=
PUSHER_PORT=443
PUSHER_SCHEME=https
PUSHER_APP_CLUSTER=mt1
```

#### Frontend (.env)
```env
VITE_API_URL=http://localhost:8000/api
VITE_PUSHER_APP_KEY=your_app_key
VITE_PUSHER_HOST=localhost
VITE_PUSHER_PORT=6001
VITE_PUSHER_SCHEME=http
VITE_PUSHER_APP_CLUSTER=mt1
```

## 📚 Documentation

- [Architecture Atomique](frontend/ATOMIC_DESIGN.md) - Guide détaillé de l'architecture des composants
- [API Documentation](backend/README.md) - Documentation de l'API Laravel

## 🚀 Fonctionnalités

### Authentification
- Inscription et connexion utilisateur
- JWT tokens avec refresh
- Gestion des sessions

### Gestion des Tâches
- Création, modification, suppression de tâches
- Filtrage par statut et priorité
- Pagination
- Recherche

### Interface Utilisateur
- Design responsive
- Composants atomiques réutilisables
- Thème personnalisable
- Mode sombre (prévu)

### Notifications
- Notifications en temps réel
- Toast notifications
- Système d'alertes

## 🛠️ Développement

### Structure du projet
```
TasksManager/
├── backend/                 # Application Laravel
│   ├── app/
│   ├── database/
│   ├── routes/
│   └── ...
├── frontend/               # Application Vue.js
│   ├── src/
│   │   ├── components/     # Composants atomiques
│   │   ├── views/          # Pages
│   │   ├── stores/         # Pinia stores
│   │   └── ...
│   └── ...
├── docker-compose.yml      # Configuration Docker
├── start.sh               # Script de démarrage
└── README.md              # Documentation
```

### Commandes utiles

#### Backend
```bash
# Accéder au conteneur backend
docker compose exec backend bash

# Exécuter les migrations
docker compose exec backend php artisan migrate

# Générer une clé d'application
docker compose exec backend php artisan key:generate

# Vider le cache
docker compose exec backend php artisan cache:clear
```

#### Frontend
```bash
# Accéder au conteneur frontend
docker compose exec frontend sh

# Installer les dépendances
docker compose exec frontend npm install

# Build en mode développement
docker compose exec frontend npm run dev

# Build en mode production
docker compose exec frontend npm run build
``

