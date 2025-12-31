# Country Currency API - Dockerization & Multi-Environment Setup

## Project Overview
**CountryCurrencyAPI** is a .NET 9 ASP.NET Core REST API that provides country information and currency exchange rates. The project fetches data from external APIs (RestCountries and ExchangeRate API) and generates summary images using SkiaSharp.

**Tech Stack:**
- .NET 9 / ASP.NET Core
- MySQL 8.0
- Docker & Docker Compose
- Entity Framework Core
- SkiaSharp (Image Generation)
- Scalar (API Documentation)

---

## Accomplished

### 1. **Complete Dockerization**
Containerized the entire application for consistent deployment across environments.

**Files Created:**
- `Dockerfile` - Multi-stage build optimized for .NET 9
- `docker-compose.dev.yml` - Development environment configuration
- `docker-compose.staging.yml` - Staging environment configuration  
- `docker-compose.prod.yml` - Production environment configuration
- `.dockerignore` - Optimized build context

**Key Docker Features:**
- Multi-stage build (reduces final image size by ~70%)
- Health checks for both API and database
- Automatic database migrations on startup
- Persistent data volumes
- Bridge networking for container communication

### 2. **Multi-Environment Architecture**
Implemented isolated environments that can run simultaneously on the same machine.

**Environment Separation:**
- **Development**: Port 8080 (API) / 3306 (DB) - `countrycurrency_dev`
- **Staging**: Port 8081 (API) / 3307 (DB) - `countrycurrency_staging`
- **Production**: Port 8082 (API) / 3308 (DB) - `countrycurrency_prod`

**Environment Files Created:**
- `.env.development` - Dev configuration
- `.env.staging` - Staging configuration
- `.env.production` - Production configuration
- `.env.example` - Template for team members

**Isolation Achieved:**
- Separate databases per environment
- Separate Docker networks
- Separate data volumes
- Different credentials per environment
- Independent container naming

### 3. **Automation Scripts**
Created shell scripts for easy environment management.

**Scripts:**
- `run-env.sh` / `run-env.bat` - Start environments
- `stop-env.sh` / `stop-env.bat` - Stop environments

**Usage:**
```bash
# Start any environment
./run-env.sh dev       # Development
./run-env.sh staging   # Staging
./run-env.sh prod      # Production

# Stop environments
./stop-env.sh dev      # Stop specific environment
./stop-env.sh all      # Stop all environments

# Check status
docker ps
```

---

## Technical Challenges & Solutions

### Challenge 1: SkiaSharp Native Dependencies
**Problem:** Application crashed with `DllNotFoundException` when generating images.

**Root Cause:** SkiaSharp requires native Linux libraries not included in base .NET images.

**Solution:** Added native dependencies to Dockerfile:
```dockerfile
RUN apt-get update && apt-get install -y \
    libfontconfig1 \
    libfreetype6 \
    libgdiplus \
    libc6-dev \
    && rm -rf /var/lib/apt/lists/*
```

**Impact:** Image generation now works correctly, enabling summary statistics PNG creation.

### Challenge 2: Scalar API Documentation Access
**Problem:** Scalar UI (interactive API docs) was inaccessible in production mode.

**Root Cause:** Scalar only renders in Development environment by default.

**Solution:** Changed `ASPNETCORE_ENVIRONMENT=Development` for local testing while keeping Production settings for deployment.

**Result:** API documentation accessible at `/scalar/v1` for development and testing.

### Challenge 3: Docker Build Caching
**Problem:** Changes to Dockerfile weren't reflected in rebuilt containers.

**Root Cause:** Docker was using cached layers from previous builds.

**Solution:** Used `docker-compose build --no-cache` to force clean rebuild.

**Lesson Learned:** Always use `--no-cache` when modifying system dependencies.

### Challenge 4: Environment Variable Loading
**Problem:** Docker Compose wasn't loading environment variables from `.env` files.

**Root Cause:** `env_file` directive doesn't export variables for `${VAR}` substitution syntax.

**Solution:** Used `--env-file` flag in docker-compose commands:
```bash
docker-compose -f docker-compose.dev.yml --env-file .env.development up -d
```

### Challenge 5: Container Name Conflicts
**Problem:** Multiple environments were overwriting each other's containers.

**Root Cause:** All docker-compose files used the same default project name.

**Solution:** Used `COMPOSE_PROJECT_NAME` environment variable to create unique container names:
```bash
COMPOSE_PROJECT_NAME=dev docker-compose -f docker-compose.dev.yml up -d
```

**Result:** Can run dev, staging, and production simultaneously without conflicts.

---

## Architecture Highlights

### Multi-Stage Docker Build
```
Stage 1 (Build): 
- Uses .NET SDK image (~1.2GB)
- Restores NuGet packages
- Compiles application

Stage 2 (Runtime):
- Uses .NET Runtime image (~200MB)
- Copies only compiled binaries
- Installs native dependencies
- Final image: ~250MB (vs 1.2GB)
```

### Health Check Strategy
```yaml
API Health Check:
- Endpoint: /status
- Interval: 30s
- Timeout: 10s
- Start Period: 60s (allows migration time)

Database Health Check:
- Command: mysqladmin ping
- Interval: 10s
- Retries: 5
- Ensures DB ready before API starts
```

### Database Migration Strategy
- Automatic migration on startup
- Retry logic (10 attempts with delays)
- Prevents race conditions
- Logs connection attempts for debugging

---

## API Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/countries/status` | GET | Returns total countries and last refresh time |
| `/countries/refresh` | POST | Fetches latest data from external APIs |
| `/countries` | GET | Lists all countries |
| `/countries/{name}` | GET | Get specific country details |
| `/countries/image` | GET | Download summary statistics PNG |
| `/scalar/v1` | GET | Interactive API documentation |

---

## Key Metrics

**Build Performance:**
- Build Time: ~45 seconds (with cache)
- Image Size: ~250MB (optimized)
- Startup Time: ~15 seconds (including migrations)

**Data Handling:**
- Countries Supported: 250+
- Database Schema: Auto-migrated via EF Core
- Image Generation: SkiaSharp with custom fonts

**Scalability:**
- Horizontal: Docker Compose can scale services
- Vertical: Resource limits configurable per container
- Environment Isolation: No cross-contamination

---

## Deployment Checklist

### Local Development
- [x] Dockerized application
- [x] Multi-environment support
- [x] Automated scripts
- [x] Health checks
- [x] Data persistence
- [x] SkiaSharp dependencies

### Production Ready
- [x] Environment variables externalized
- [x] Secure credential management
- [x] Database connection pooling
- [x] Automatic migrations
- [x] Restart policies
- [x] Logging enabled

### Next Steps (Deployment)
- [ ] Push to GitHub
- [ ] Deploy to Railway/Cloud
- [ ] Configure production environment variables
- [ ] Set up CI/CD pipeline
- [ ] Monitor application health
- [ ] Configure backups

---

## Commands Reference

### Development Workflow
```bash
# Start development environment
./run-env.sh dev

# Refresh country data
curl -X POST http://localhost:8080/countries/refresh

# Check status
curl http://localhost:8080/countries/status

# View logs
docker logs dev-api-1 --tail=50 -f

# Stop environment
./stop-env.sh dev
```

### Debugging
```bash
# Rebuild from scratch
docker-compose build --no-cache

# Check container health
docker ps

# View database logs
COMPOSE_PROJECT_NAME=dev docker-compose -f docker-compose.dev.yml logs db

# Enter container shell
docker exec -it dev-api-1 /bin/bash

# Check database connection
docker exec -it dev-db-1 mysql -u appuser_dev -p countrycurrency_dev
```

### Environment Management
```bash
# Run multiple environments simultaneously
./run-env.sh dev
./run-env.sh staging
./run-env.sh prod

# Stop all environments
./stop-env.sh all

# Check running environments
docker ps --format "table {{.Names}}\t{{.Ports}}\t{{.Status}}"
```

---

## Interview Talking Points

### Problem-Solving Skills
"Encountered a DllNotFoundException with SkiaSharp. Debugged by analyzing container logs, identified missing native Linux dependencies, and resolved by adding libgdiplus and libc6-dev to the Dockerfile."

### DevOps Knowledge
"Implemented multi-environment Docker setup with isolated databases, networks, and volumes. Used environment variables for configuration management and created automation scripts for streamlined deployment."

### System Design
"Designed a scalable architecture using Docker Compose with health checks, automatic migrations, and multi-stage builds. Achieved 70% image size reduction while maintaining all functionality."

### Learning & Adaptation
"When Docker caching caused issues, learned to use --no-cache flag strategically. When environment variables weren't loading, researched Docker Compose documentation and implemented --env-file solution."

### Best Practices
"Followed Docker best practices: multi-stage builds, .dockerignore optimization, health checks, restart policies, and secrets management through environment files excluded from version control."

---

## Technical Decisions & Rationale

**Why Multi-Stage Builds?**
- Reduces final image size (1.2GB → 250MB)
- Improves deployment speed
- Separates build dependencies from runtime

**Why Separate Environment Files?**
- Prevents credential leakage
- Allows different configurations per environment
- Enables team collaboration without conflicts

**Why Health Checks?**
- Ensures containers are truly ready (not just started)
- Prevents premature traffic routing
- Enables automatic recovery

**Why Project Name Separation?**
- Allows simultaneous environments on same machine
- Prevents container name collisions
- Easier debugging and management

---

## Learning Outcomes

1. **Docker Mastery**: Multi-stage builds, compose orchestration, networking, volumes
2. **.NET Deployment**: Understanding of runtime vs SDK images, dependency management
3. **Linux System Administration**: Native library dependencies, package management
4. **Database Management**: MySQL in containers, migrations, health checks
5. **DevOps Practices**: Environment isolation, automation, configuration management
6. **Debugging Skills**: Log analysis, container inspection, network troubleshooting

---

## Project Statistics

- **Files Created**: 12 (Docker configs, env files, scripts, documentation)
- **Docker Images**: 1 custom application image
- **Containers**: Up to 6 (3 environments × 2 containers each)
- **Networks**: 3 isolated bridge networks
- **Volumes**: 3 persistent data volumes
- **Environments**: 3 fully isolated configurations
- **Lines of Code**: ~500+ (Docker, scripts, configs)

---

**Date Completed**: December 31, 2025  
**Technology**: .NET 9, Docker, MySQL, SkiaSharp  
**Outcome**: Production-ready multi-environment deployment system
