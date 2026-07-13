# Docker + Kubernetes — Paralelo API UTESA

## Estructura del proyecto

```
kubernetes/
├── backend/
│   └── Dockerfile          ← imagen del backend Go
├── frontend/
│   ├── index.html          ← app web que consume la API
│   └── Dockerfile          ← imagen nginx con el frontend
├── k8s/
│   ├── secrets.yaml        ← credenciales (configurar antes)
│   ├── backend-deployment.yaml   ← Deployment + Service backend
│   └── frontend-deployment.yaml  ← Deployment + Service frontend
└── README.md
```

---

## Requisitos previos

- Docker Desktop instalado y corriendo
- Kubernetes habilitado en Docker Desktop:
  Docker Desktop → Settings → Kubernetes → Enable Kubernetes ✅

Verifica:
```bash
kubectl version
docker --version
```

---

## Paso 1 — Copiar el código fuente del backend

El Dockerfile del backend necesita el código Go. Copia toda la carpeta `paralelo` (el backend) dentro de `kubernetes/backend/`:

```
kubernetes/backend/
├── Dockerfile
├── go.mod
├── go.sum
├── cmd/
└── internal/
```

En PowerShell:
```bash
xcopy /E /I paralelo\* kubernetes\backend\
```

---

## Paso 2 — Configurar los secrets

Edita `k8s/secrets.yaml` y reemplaza con tus valores reales:
```yaml
database-url: "postgresql://usuario:password@ep-xxx.neon.tech/paralelo_db?sslmode=require"
jwt-secret: "paralelo_utesa_jwt_secret_2024"
sns-topic-arn: "arn:aws:sns:us-east-1:913407539509:paralelo-notifications"
```

---

## Paso 3 — Construir las imágenes Docker

```bash
# Backend
docker build -t paralelo-backend:latest kubernetes/backend/

# Frontend
docker build -t paralelo-frontend:latest kubernetes/frontend/

# Verificar imágenes creadas
docker images | grep paralelo
```

---

## Paso 4 — Aplicar configuración en Kubernetes

```bash
# Aplicar secrets primero
kubectl apply -f kubernetes/k8s/secrets.yaml

# Desplegar backend (2 réplicas)
kubectl apply -f kubernetes/k8s/backend-deployment.yaml

# Desplegar frontend
kubectl apply -f kubernetes/k8s/frontend-deployment.yaml

# Verificar que todo está corriendo
kubectl get pods
kubectl get deployments
kubectl get svc
```

---

## Paso 5 — Escalar el backend a 5 réplicas

```bash
kubectl scale deployment paralelo-backend --replicas=5

# Verificar el escalado
kubectl get pods
kubectl get deployments
```

---

## Paso 6 — Acceder a la aplicación

- **Frontend:** http://localhost:30081
- **Backend API:** http://localhost:30080/api

---

## Comandos útiles para evidencias

```bash
# Ver imágenes Docker
docker images

# Ver todos los pods
kubectl get pods

# Ver deployments
kubectl get deployments

# Ver servicios
kubectl get svc

# Ver logs de un pod del backend
kubectl logs -l app=paralelo-backend

# Describir el deployment
kubectl describe deployment paralelo-backend

# Escalar a 5 réplicas
kubectl scale deployment paralelo-backend --replicas=5

# Volver a 2 réplicas
kubectl scale deployment paralelo-backend --replicas=2

# Eliminar todo
kubectl delete -f kubernetes/k8s/
```
