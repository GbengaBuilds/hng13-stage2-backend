# Deployment Guide

## Docker Deployment

### Prerequisites
- Docker installed
- Docker Compose installed

### Local Development with Docker Compose

1. **Build and run the containers:**
   ```bash
   docker-compose up --build
   ```

2. **Run in detached mode:**
   ```bash
   docker-compose up -d
   ```

3. **View logs:**
   ```bash
   docker-compose logs -f api
   ```

4. **Stop containers:**
   ```bash
   docker-compose down
   ```

5. **Stop and remove volumes:**
   ```bash
   docker-compose down -v
   ```

The API will be available at `http://localhost:8080`

### Build Docker Image Only

```bash
docker build -t country-currency-api .
```

### Run Docker Container Manually

```bash
docker run -p 8080:8080 \
  -e MYSQLHOST=your-db-host \
  -e MYSQLPORT=3306 \
  -e MYSQLDATABASE=countrycurrency \
  -e MYSQLUSER=appuser \
  -e MYSQLPASSWORD=yourpassword \
  country-currency-api
```

## Railway Deployment

### Option 1: Deploy from GitHub

1. Push your code to GitHub
2. Go to [Railway.app](https://railway.app)
3. Click "New Project" → "Deploy from GitHub repo"
4. Select your repository
5. Add a MySQL database service
6. Railway will auto-detect the Dockerfile and build

### Option 2: Deploy using Railway CLI

1. **Install Railway CLI:**
   ```bash
   npm install -g @railway/cli
   ```

2. **Login to Railway:**
   ```bash
   railway login
   ```

3. **Initialize project:**
   ```bash
   railway init
   ```

4. **Add MySQL database:**
   - Go to Railway dashboard
   - Click "New" → "Database" → "MySQL"
   - Railway will provide connection variables

5. **Deploy:**
   ```bash
   railway up
   ```

### Environment Variables for Railway

Railway automatically provides these variables when you add MySQL:
- `MYSQLHOST`
- `MYSQLPORT`
- `MYSQLDATABASE`
- `MYSQLUSER`
- `MYSQLPASSWORD`

Or it may provide:
- `MYSQL_URL` (format: mysql://user:password@host:port/database)

The app is configured to handle both formats automatically.

## Azure Container Apps Deployment

1. **Build and push to Azure Container Registry:**
   ```bash
   az acr build --registry <your-acr-name> --image country-currency-api:latest .
   ```

2. **Deploy to Container Apps:**
   ```bash
   az containerapp create \
     --name country-currency-api \
     --resource-group <your-rg> \
     --environment <your-env> \
     --image <your-acr-name>.azurecr.io/country-currency-api:latest \
     --target-port 8080 \
     --ingress external \
     --env-vars \
       MYSQLHOST=<your-db-host> \
       MYSQLPORT=3306 \
       MYSQLDATABASE=countrycurrency \
       MYSQLUSER=<your-user> \
       MYSQLPASSWORD=<your-password>
   ```

## AWS ECS/Fargate Deployment

1. **Create ECR repository:**
   ```bash
   aws ecr create-repository --repository-name country-currency-api
   ```

2. **Build and push:**
   ```bash
   aws ecr get-login-password --region <region> | docker login --username AWS --password-stdin <account-id>.dkr.ecr.<region>.amazonaws.com
   docker build -t country-currency-api .
   docker tag country-currency-api:latest <account-id>.dkr.ecr.<region>.amazonaws.com/country-currency-api:latest
   docker push <account-id>.dkr.ecr.<region>.amazonaws.com/country-currency-api:latest
   ```

3. **Create ECS task definition and service** with environment variables for database connection

## Google Cloud Run Deployment

1. **Build and push to Google Container Registry:**
   ```bash
   gcloud builds submit --tag gcr.io/<project-id>/country-currency-api
   ```

2. **Deploy to Cloud Run:**
   ```bash
   gcloud run deploy country-currency-api \
     --image gcr.io/<project-id>/country-currency-api \
     --platform managed \
     --region <region> \
     --allow-unauthenticated \
     --set-env-vars MYSQLHOST=<host>,MYSQLPORT=3306,MYSQLDATABASE=countrycurrency,MYSQLUSER=<user>,MYSQLPASSWORD=<password>
   ```

## Health Check

After deployment, verify the API is running:

```bash
curl http://your-api-url/status
```

## Initial Data Setup

After deployment, trigger the initial data fetch:

```bash
curl -X POST http://your-api-url/countries/refresh
```

## Troubleshooting

### Connection Issues
- Check database connection string in logs
- Verify environment variables are set correctly
- Ensure database allows connections from your container IP

### Image Generation Issues
- SkiaSharp dependencies are installed in the Dockerfile
- Check logs for font-related errors

### Migration Issues
- Migrations run automatically on startup
- Check logs for database migration errors
- Ensure database user has CREATE/ALTER permissions
