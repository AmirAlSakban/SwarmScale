# Project Requirements

This document outlines the requirements for the Docker Swarm Node.js application with Nginx load balancer project and explains how they are met.

## Core Requirements

1. **Node.js Application**
   - [x] Create a Node.js application that handles HTTP GET requests to `/whoami`
   - [x] Application responds with the hostname on which it's running
   - [x] Application runs on port 8081
   - [x] Application is containerized using Docker

2. **Nginx Load Balancer**
   - [x] Nginx server acts as a load balancer for Node.js containers
   - [x] Nginx is containerized using Docker
   - [x] Configuration uses the least connections balancing strategy

3. **Docker Swarm Deployment**
   - [x] Node.js and Nginx are deployed using Docker Swarm
   - [x] Nginx server is deployed only once on the manager node
   - [x] Node.js application is deployed with 10 replicas
   - [x] Docker Visualizer is used to show running containers

## Implementation Details

### Node.js Application
The Node.js application is implemented using Express.js and responds to GET requests at the `/whoami` endpoint with an HTML response containing the hostname.

```javascript
const express = require('express')
const app = express()
const os = require('os');
app.get('/whoami', function(req, res) {
    res.send(`<h3>I am ${os.hostname()}</h3>`);
})
app.listen(8081, function() {
    console.log('app listening on port 8081!')
})
```

### Nginx Load Balancer
The Nginx load balancer is configured to distribute requests to the `/whoami` endpoint across all Node.js container instances using the least connections algorithm.

```nginx
upstream loadbalance {
    least_conn;
    server node-app:8081;
}

server {
    listen 80;
    location /whoami {
        proxy_pass http://loadbalance;
    }
}
```

### Docker Swarm Deployment
The application is deployed using Docker Swarm with a constraint to ensure the Nginx service runs only on the manager node:

```yaml
nginx:
  image: nginx-lb:latest
  ports:
    - "80:80"
  deploy:
    replicas: 1
    placement:
      constraints: [node.role == manager]

node-app:
  image: node-app:latest
  deploy:
    replicas: 10
    restart_policy:
      condition: on-failure
```

## Verification

The deployment can be verified by:
1. Accessing `http://localhost/whoami` multiple times and observing different hostnames
2. Using Docker Visualizer at `http://localhost:8080` to see the container distribution
3. Running `docker service ls` to confirm the correct number of replicas
