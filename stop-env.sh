#!/bin/bash

# Script to stop different environments
ENV=${1:-dev}

case $ENV in
  dev|development)
    echo "Stopping DEVELOPMENT environment..."
    docker-compose -f docker-compose.dev.yml down
    ;;
  staging)
    echo "Stopping STAGING environment..."
    docker-compose -f docker-compose.staging.yml down
    ;;
  prod|production)
    echo "Stopping PRODUCTION environment..."
    docker-compose -f docker-compose.prod.yml down
    ;;
  all)
    echo "Stopping ALL environments..."
    docker-compose -f docker-compose.dev.yml down
    docker-compose -f docker-compose.staging.yml down
    docker-compose -f docker-compose.prod.yml down
    ;;
  *)
    echo "Usage: ./stop-env.sh [dev|staging|prod|all]"
    exit 1
    ;;
esac

echo "Environment stopped!"