# Docker Swarm Node.js Application with Nginx Load Balancer

This project demonstrates a Node.js application that is scaled to multiple instances and load-balanced using an Nginx server. The stack is deployed using Docker Swarm, meeting the following requirements:
- A Node.js application handling requests on `/whoami` and responding with the hostname
- Nginx as a load balancer for the Node.js containers
- Docker Swarm deployment with 10 replicas of the Node.js app
- Visualizer to monitor container distribution

## Project Structure

- `app/`: Node.js application
  - `server.js`: Application code that responds with the container hostname
  - `package.json`: Dependencies (Express.js)
  - `Dockerfile`: Docker configuration for Node.js app

- `nginx/`: Nginx load balancer
  - `nginx.conf`: Configuration for load balancing using least connections
  - `Dockerfile`: Docker configuration for Nginx

- `docker-compose.yml`: For local development testing
- `docker-stack.yml`: For Docker Swarm deployment
- `.gitignore`: Git ignore configuration
- `setup-swarm.bat`: Helper script for Windows to set up Docker Swarm

## Prerequisites

- Docker Engine (Docker Desktop for Windows/Mac or Docker Engine for Linux)
- Docker Compose (included in Docker Desktop)
- Docker Swarm initialized on at least two nodes for a real multi-node setup

## Quick Start Guide

### Local Development Testing

For testing the application locally before deployment:

1. Build and run the services locally:

```bash
docker-compose up --build
```

2. Access `http://localhost/whoami` to see the Node.js app response.

### Docker Swarm Deployment (Single Node)

For a quick deployment on a single node:

1. Initialize Docker Swarm:

```bash
docker swarm init
```

2. Build the local images:

```bash
docker build -t node-app:latest ./app
docker build -t nginx-lb:latest ./nginx
```

3. Deploy the stack with local images:

```bash
docker stack deploy -c docker-stack.yml swarm-demo
```

### Docker Swarm Deployment (Multiple Nodes)

For a production deployment across multiple nodes:

1. Initialize Docker Swarm on the manager node:

```bash
docker swarm init
```

2. Join worker nodes to the swarm using the command provided by the above init command:

```bash
docker swarm join --token <token> <manager-ip>:2377
```

3. Either build and push the images to Docker Hub:

```bash
# Build images
docker build -t yourusername/node-app:latest ./app
docker build -t yourusername/nginx-load-balancer:latest ./nginx

# Push images to Docker Hub (requires Docker Hub account and login)
docker push yourusername/node-app:latest
docker push yourusername/nginx-load-balancer:latest
```

4. Update the `docker-stack.yml` file to use your Docker Hub images:

```yaml
services:
  nginx:
    image: yourusername/nginx-load-balancer:latest
    # ...

  node-app:
    image: yourusername/node-app:latest
    # ...
```

5. Deploy the stack to Docker Swarm:

```bash
docker stack deploy -c docker-stack.yml swarm-demo
```

## Testing Your Deployment

1. Access the application:
   - URL: `http://localhost/whoami` (for local deployment) 
   - URL: `http://<manager-node-ip>/whoami` (for multi-node deployment)

2. Access the Docker Visualizer to see container distribution:
   - URL: `http://localhost:8080` (for local deployment)
   - URL: `http://<manager-node-ip>:8080` (for multi-node deployment)

3. Verify the load balancing by refreshing the `/whoami` URL multiple times. You should see different hostnames in the response, indicating that requests are being distributed across different containers.

## Verifying and Troubleshooting

### Check Deployment Status

```bash
# List all services and their status
docker service ls

# Verify that the Node.js application has 10 replicas
docker service ps swarm-demo_node-app

# Check logs for a service
docker service logs swarm-demo_node-app
```

### Advanced Testing

```bash
# Make multiple requests to confirm load balancing
for /L %i in (1,1,5) do curl http://localhost/whoami
```

## Scaling and Updates

You can scale services on the fly:

```bash
# Scale to a different number of replicas
docker service scale swarm-demo_node-app=15
```

## Shutting Down

When finished with the project:

```bash
# Remove the stack
docker stack rm swarm-demo

# Leave the swarm (on worker nodes)
docker swarm leave

# Leave the swarm (on manager node)
docker swarm leave --force
```
