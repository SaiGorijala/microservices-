# MicroDash — Microservices Web Application

A clean, Kubernetes-ready microservices application with segregated folders for independent pod deployment.

## 📁 Project Structure

```
microservices-app/
├── frontend/                  → Nginx + HTML dashboard (Pod 1)
│   ├── index.html
│   ├── nginx.conf
│   └── Dockerfile
│
├── services/
│   ├── user-service/          → Node.js REST API for users (Pod 2)
│   │   ├── index.js
│   │   ├── package.json
│   │   └── Dockerfile
│   │
│   └── product-service/       → Node.js REST API for products (Pod 3)
│       ├── index.js
│       ├── package.json
│       └── Dockerfile
│
├── database/                  → PostgreSQL with init scripts (Pod 4)
│   ├── migrations/
│   │   └── 001_init.sql
│   ├── seeds/
│   │   └── 001_seed.sql
│   ├── init.sh
│   └── Dockerfile
│
├── k8s/                       → Kubernetes manifests
│   ├── secret.yaml
│   ├── postgres.yaml
│   ├── user-service.yaml
│   ├── product-service.yaml
│   └── frontend.yaml
│
└── docker-compose.yml         → Local dev (all services together)
```

## 🚀 Quick Start — Docker Compose (Local Dev)

```bash
docker-compose up --build
```

Then open: http://localhost:8080

Services available at:
- Frontend:        http://localhost:8080
- User Service:    http://localhost:3001
- Product Service: http://localhost:3002
- PostgreSQL:      localhost:5432

---

## ☸️ Kubernetes Deployment

### 1. Build & push images

```bash
# Replace 'your-registry' with your Docker Hub or private registry
docker build -t your-registry/postgres:latest       ./database
docker build -t your-registry/user-service:latest   ./services/user-service
docker build -t your-registry/product-service:latest ./services/product-service
docker build -t your-registry/frontend:latest        ./frontend

docker push your-registry/postgres:latest
docker push your-registry/user-service:latest
docker push your-registry/product-service:latest
docker push your-registry/frontend:latest
```

### 2. Update image names in k8s/*.yaml

Replace `your-registry/...` with your actual image paths.

### 3. Apply manifests

```bash
kubectl apply -f k8s/secret.yaml
kubectl apply -f k8s/postgres.yaml
kubectl apply -f k8s/user-service.yaml
kubectl apply -f k8s/product-service.yaml
kubectl apply -f k8s/frontend.yaml
```

### 4. Check pods

```bash
kubectl get pods
kubectl get services
```

---

## 🔌 API Endpoints

### User Service (port 3001)
| Method | Path             | Description    |
|--------|-----------------|----------------|
| GET    | /health          | Health check   |
| GET    | /api/users       | List all users |
| GET    | /api/users/:id   | Get user by ID |
| POST   | /api/users       | Create user    |
| DELETE | /api/users/:id   | Delete user    |

### Product Service (port 3002)
| Method | Path                | Description       |
|--------|---------------------|-------------------|
| GET    | /health             | Health check      |
| GET    | /api/products       | List all products |
| GET    | /api/products/:id   | Get product by ID |
| POST   | /api/products       | Create product    |
| DELETE | /api/products/:id   | Delete product    |

---

## ⚙️ Environment Variables

Each service reads from environment variables — set these in k8s Secrets/ConfigMaps or docker-compose.yml:

| Variable      | Default    | Used By              |
|---------------|-----------|----------------------|
| DB_HOST       | localhost  | user-svc, product-svc|
| DB_PORT       | 5432       | user-svc, product-svc|
| DB_NAME       | appdb      | user-svc, product-svc|
| DB_USER       | postgres   | user-svc, product-svc|
| DB_PASSWORD   | postgres   | user-svc, product-svc|
| PORT          | 3001/3002  | each service         |
