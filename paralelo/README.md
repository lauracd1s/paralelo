# Paralelo - API REST en Go con Arquitectura Hexagonal

## 📐 Arquitectura Hexagonal aplicada

```
paralelo/
├── cmd/
│   └── api/
│       └── main.go                  ← Punto de entrada, inyección de dependencias
│
├── internal/
│   ├── core/                        ← NÚCLEO (independiente de frameworks)
│   │   ├── domain/
│   │   │   └── user.go             ← Entidad de dominio
│   │   ├── ports/
│   │   │   └── ports.go            ← Interfaces (contratos)
│   │   └── services/
│   │       └── user_service.go     ← Lógica de negocio
│   │
│   ├── adapters/
│   │   ├── primary/                ← ADAPTADORES PRIMARIOS (entrada)
│   │   │   └── http/
│   │   │       ├── handlers/       ← Manejadores HTTP (Gin)
│   │   │       ├── middleware/     ← Middleware JWT
│   │   │       └── router/        ← Configuración de rutas
│   │   │
│   │   └── secondary/             ← ADAPTADORES SECUNDARIOS (salida)
│   │       └── postgres/
│   │           └── repositories/  ← Implementación PostgreSQL
│   │
│   └── infrastructure/
│       └── database/
│           └── postgres.go        ← Conexión y migración BD
│
├── scripts/
│   └── init.sql                   ← Script SQL inicial
├── .env                           ← Variables de entorno
└── go.mod
```

## 🚀 Instalación y ejecución

### 1. Requisitos previos
- Go 1.22+
- PostgreSQL instalado y corriendo

### 2. Clonar y configurar
```bash
# Navegar a la carpeta del proyecto
cd C:\Users\laura\Desktop\UTESA\10mo cuatriestre\paralelo

# Instalar dependencias
go mod tidy

# Copiar y editar las variables de entorno
# Editar .env con tu contraseña de PostgreSQL
```

### 3. Crear la base de datos
```sql
-- En psql o pgAdmin ejecutar:
CREATE DATABASE paralelo_db;
```
*(La tabla se crea automáticamente al iniciar la API)*

### 4. Ejecutar la API
```bash
go run cmd/api/main.go
```

---

## 📡 Endpoints de la API

### Autenticación (públicos)

| Método | Ruta | Descripción |
|--------|------|-------------|
| POST | `/api/auth/register` | Registrar nuevo usuario |
| POST | `/api/auth/login` | Iniciar sesión, devuelve JWT |

### CRUD Usuarios (requieren JWT)

| Método | Ruta | Descripción |
|--------|------|-------------|
| GET | `/api/usuarios` | Listar todos los usuarios |
| GET | `/api/usuarios/:id` | Obtener usuario por ID |
| PUT | `/api/usuarios/:id` | Actualizar usuario |
| DELETE | `/api/usuarios/:id` | Eliminar usuario |

---

## 🧪 Ejemplos de uso con curl

### Registrar usuario
```bash
curl -X POST http://localhost:8080/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "nombre": "Laura García",
    "email": "laura@utesa.edu",
    "password": "123456",
    "rol": "estudiante"
  }'
```

### Login
```bash
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "laura@utesa.edu",
    "password": "123456"
  }'
```
*Responde con un token JWT — guárdalo para los siguientes requests*

### Listar usuarios (con JWT)
```bash
curl http://localhost:8080/api/usuarios \
  -H "Authorization: Bearer <TU_TOKEN_AQUI>"
```

### Obtener usuario por ID
```bash
curl http://localhost:8080/api/usuarios/1 \
  -H "Authorization: Bearer <TU_TOKEN_AQUI>"
```

### Actualizar usuario
```bash
curl -X PUT http://localhost:8080/api/usuarios/1 \
  -H "Authorization: Bearer <TU_TOKEN_AQUI>" \
  -H "Content-Type: application/json" \
  -d '{
    "nombre": "Laura García Actualizada"
  }'
```

### Eliminar usuario
```bash
curl -X DELETE http://localhost:8080/api/usuarios/1 \
  -H "Authorization: Bearer <TU_TOKEN_AQUI>"
```

---

## 🔑 Principios de Arquitectura Hexagonal aplicados

| Concepto | Implementación |
|----------|---------------|
| **Dominio** | `internal/core/domain/user.go` — entidad pura sin dependencias |
| **Puertos** | `internal/core/ports/ports.go` — interfaces `UserService` y `UserRepository` |
| **Servicio** | `internal/core/services/` — lógica de negocio, solo depende de puertos |
| **Adaptador primario** | `handlers/`, `middleware/`, `router/` — Gin como driver |
| **Adaptador secundario** | `repositories/` — PostgreSQL como driven |
| **Inyección de dependencias** | `cmd/api/main.go` — todo se ensambla aquí |
