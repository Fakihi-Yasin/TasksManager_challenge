#!/bin/bash

echo "🚀 Démarrage de Tasks Manager - Application To-Do List Full Stack"
echo "================================================================"

# Vérifier si Docker est installé
if ! command -v docker &> /dev/null; then
    echo "❌ Docker n'est pas installé. Veuillez installer Docker d'abord."
    exit 1
fi

# Vérifier si Docker Compose est installé (support V1 et V2)
if command -v docker-compose &> /dev/null; then
    DOCKER_COMPOSE_CMD="docker-compose"
elif docker compose version &> /dev/null; then
    DOCKER_COMPOSE_CMD="docker compose"
else
    echo "❌ Docker Compose n'est pas installé. Veuillez installer Docker Compose d'abord."
    exit 1
fi

echo "✅ Docker et Docker Compose sont installés (commande: $DOCKER_COMPOSE_CMD)"

# Créer les fichiers .env s'ils n'existent pas
if [ ! -f "backend/.env" ]; then
    echo "📝 Création du fichier .env pour le backend..."
    cp backend/.env.example backend/.env
    echo "✅ Fichier .env backend créé"
else
    echo "✅ Fichier .env backend existe déjà"
fi

if [ ! -f "frontend/.env" ]; then
    echo "📝 Création du fichier .env pour le frontend..."
    cp frontend/.env.example frontend/.env
    echo "✅ Fichier .env frontend créé"
else
    echo "✅ Fichier .env frontend existe déjà"
fi

# Construire et démarrer les containers
echo "🔨 Construction et démarrage des containers Docker..."
$DOCKER_COMPOSE_CMD up -d --build

# Attendre que les services soient prêts
echo "⏳ Attente que les services soient prêts..."
sleep 30

# Installation des dépendances backend
echo "📦 Installation des dépendances Laravel..."
$DOCKER_COMPOSE_CMD exec -T app composer install --no-interaction

# Génération des clés
echo "🔑 Génération des clés Laravel..."
$DOCKER_COMPOSE_CMD exec -T app php artisan key:generate --no-interaction
$DOCKER_COMPOSE_CMD exec -T app php artisan jwt:secret --no-interaction

# Exécution des migrations
echo "🗄️ Exécution des migrations de base de données..."
$DOCKER_COMPOSE_CMD exec -T app php artisan migrate --force

# Création du lien symbolique pour le stockage
echo "🔗 Création du lien symbolique pour le stockage..."
$DOCKER_COMPOSE_CMD exec -T app php artisan storage:link --force

# Installation des dépendances frontend
echo "📦 Installation des dépendances Vue.js..."
$DOCKER_COMPOSE_CMD exec -T frontend npm install

echo ""
echo "🎉 Installation terminée avec succès!"
echo ""
echo "📱 Accès à l'application:"
echo "   Frontend: http://localhost:3000"
echo "   Backend API: http://localhost:8000/api"
echo ""
echo "📚 Documentation:"
echo "   Consultez le fichier README.md pour plus d'informations"
echo ""
echo "⚠️  IMPORTANT:"
echo "   N'oubliez pas de configurer vos clés Pusher dans les fichiers .env"
echo "   pour que les WebSockets fonctionnent correctement."
echo ""
echo "🔧 Commandes utiles:"
echo "   Voir les logs: $DOCKER_COMPOSE_CMD logs -f"
echo "   Arrêter l'app: $DOCKER_COMPOSE_CMD down"
echo "   Redémarrer: $DOCKER_COMPOSE_CMD restart"
echo ""
echo "✨ Bon développement!" 