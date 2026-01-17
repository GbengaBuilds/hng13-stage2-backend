# GitHub Codespaces Configuration

This directory contains the configuration for GitHub Codespaces, which provides a complete development environment in the cloud.

## What is GitHub Codespaces?

GitHub Codespaces creates a cloud-based development environment for your repository. When you open this repository in a Codespace, it will automatically:

1. Set up a .NET 9 development environment
2. Start a MySQL 8.0 database
3. Install all necessary dependencies
4. Configure VS Code with recommended extensions
5. Forward the necessary ports (8080 for API, 3306 for database)

## How to Use

### Option 1: Via GitHub Website
1. Navigate to the repository on GitHub
2. Click the green "Code" button
3. Select the "Codespaces" tab
4. Click "Create codespace on main" (or your branch)

### Option 2: Via VS Code
1. Install the "GitHub Codespaces" extension in VS Code
2. Open the Command Palette (Ctrl+Shift+P / Cmd+Shift+P)
3. Type "Codespaces: Create New Codespace"
4. Select this repository

## What's Included

### Development Tools
- .NET 9 SDK
- Git
- GitHub CLI

### VS Code Extensions
- C# Dev Kit (ms-dotnettools.csdevkit)
- C# (ms-dotnettools.csharp)
- .NET Runtime (ms-dotnettools.vscode-dotnet-runtime)
- .NET Test Explorer
- C# Sort Usings
- C# Extensions
- EditorConfig
- REST Client (for testing API endpoints)

### Services
- **API**: Runs on port 8080
- **MySQL Database**: Runs on port 3306

## After Codespace Starts

Once your Codespace is ready, the following commands will have run automatically:
- `dotnet restore` - Restores NuGet packages
- `dotnet build` - Builds the solution

### Running the Application

The application uses Docker Compose and will start automatically. You can access:

- **API**: `http://localhost:8080`
- **API Documentation**: `http://localhost:8080/scalar/v1`
- **Health Check**: `http://localhost:8080/status`

### Useful Commands

```bash
# Build the application
dotnet build

# Run tests
dotnet test

# Watch for changes and rebuild
dotnet watch run --project src/CountryCurrencyAPI

# Check running containers
docker ps

# View API logs
docker-compose -f docker-compose.dev.yml logs -f api

# View database logs
docker-compose -f docker-compose.dev.yml logs -f db
```

## Environment Variables

The Codespace uses the `.env.development` file which contains safe default values for development:

- Database: `countrycurrency_dev`
- Database User: `appuser_dev`
- Default passwords are set (safe for development only)

If you need to use the Exchange Rate API, add your API key to the `.env.development` file:
```
EXCHANGE_RATE_API_KEY=your_api_key_here
```

## Troubleshooting

### Database Connection Issues
If you can't connect to the database, make sure the database container is healthy:
```bash
docker-compose -f docker-compose.dev.yml ps
```

### Port Forwarding
Codespaces automatically forwards ports 8080 and 3306. Check the "Ports" tab in VS Code to see the forwarded URLs.

### Rebuild Container
If something goes wrong, you can rebuild the dev container:
1. Open Command Palette (Ctrl+Shift+P / Cmd+Shift+P)
2. Type "Codespaces: Rebuild Container"
3. Select the option and wait for rebuild

## Configuration Files

- `devcontainer.json` - Main configuration file
- `../docker-compose.dev.yml` - Docker Compose configuration used by Codespaces
- `../.env.development` - Environment variables for development

## More Information

- [GitHub Codespaces Documentation](https://docs.github.com/en/codespaces)
- [Dev Containers Documentation](https://containers.dev/)
