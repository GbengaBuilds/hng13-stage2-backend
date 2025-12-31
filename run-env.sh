#!/bin/bash

# Script to run different environments
ENV=${1:-dev}

case $ENV in
  dev|development)
    echo "Starting DEVELOPMENT environment on port 8080..."
    COMPOSE_PROJECT_NAME=dev docker-compose  -f docker-compose.dev.yml --env-file .env.development up -d
    ;;
  staging)
    echo "Starting STAGING environment on port 8081..."
    COMPOSE_PROJECT_NAME=staging docker-compose  -f docker-compose.staging.yml --env-file .env.staging up -d
    ;;
  prod|production)
    echo "Starting PRODUCTION environment on port 8082..."
    COMPOSE_PROJECT_NAME=production docker-compose  -f docker-compose.prod.yml --env-file .env.production up -d
    ;;
  *)
    echo "Usage: ./run-env.sh [dev|staging|prod]"
    exit 1
    ;;
esac

echo "Environment: $ENV is now running!"
echo "Check status: docker-compose -f docker-compose.$ENV.yml ps"