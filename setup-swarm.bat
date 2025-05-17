@echo off
echo =============================================================
echo Docker Swarm Node.js with Nginx Load Balancer - Setup Script
echo =============================================================
echo.

REM Check if Docker is running
docker info > nul 2>&1
if %errorlevel% neq 0 (
    echo Docker is not running. Please start Docker Desktop and try again.
    exit /b 1
)

echo Docker is running. Proceeding with setup...
echo.

:MENU
echo Choose an option:
echo 1. Initialize Docker Swarm and build local images
echo 2. Deploy stack with local images
echo 3. Remove deployed stack
echo 4. Leave Docker Swarm
echo 5. Exit
echo.
set /p option="Enter your choice (1-5): "

if "%option%"=="1" goto INIT
if "%option%"=="2" goto DEPLOY
if "%option%"=="3" goto REMOVE
if "%option%"=="4" goto LEAVE
if "%option%"=="5" goto END
echo Invalid option. Please try again.
goto MENU

:INIT
echo.
echo Initializing Docker Swarm...
docker swarm init
if %errorlevel% neq 0 (
    echo Failed to initialize swarm. It might already be initialized.
    echo Proceeding to build images...
) else (
    echo Swarm initialized successfully!
)
echo.
echo Building Docker images...
echo Building Node.js application image...
docker build -t node-app:latest ./app
echo Building Nginx load balancer image...
docker build -t nginx-lb:latest ./nginx
echo.
echo Images built successfully!
echo.
goto MENU

:DEPLOY
echo.
echo Deploying stack to Docker Swarm...
docker stack deploy -c docker-stack.yml swarm-demo
echo.
echo Stack deployed! Services are starting...
echo You can access the application at: http://localhost/whoami
echo You can access the Docker Visualizer at: http://localhost:8080
echo.
goto MENU

:REMOVE
echo.
echo Removing deployed stack...
docker stack rm swarm-demo
echo.
echo Stack removed!
echo.
goto MENU

:LEAVE
echo.
echo WARNING: This will remove this node from the swarm.
set /p confirm="Are you sure you want to proceed? (y/n): "
if /i "%confirm%"=="y" (
    echo Leaving swarm...
    docker swarm leave --force
    echo Node removed from swarm!
) else (
    echo Operation cancelled.
)
echo.
goto MENU

:END
echo.
echo Thank you for using the setup script!
echo.
