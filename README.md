# Despliegue Serverless — Paralelo API en AWS

## Arquitectura

```
Flutter App
     │
     ▼
API Gateway (HTTP API)
     │
     ▼
AWS Lambda (Go binary)
     │
     ├──▶ Neon PostgreSQL (cloud)
     └──▶ S3 Bucket (archivos)

GitHub push
     │
     ▼
GitHub Actions
     ├── Build Go → function.zip
     └── Terraform apply → AWS
```

---

## Paso 1 — Crear cuenta en Neon PostgreSQL (gratis)

1. Ve a https://neon.tech y crea una cuenta gratis
2. Crea un nuevo proyecto llamado `paralelo`
3. Copia la **Connection String** que se ve así:
   ```
   postgresql://user:password@ep-xxx.us-east-1.aws.neon.tech/neondb?sslmode=require
   ```
4. Guárdala — la necesitas en el Paso 4

---

## Paso 2 — Crear cuenta AWS y obtener credenciales

1. Ve a https://aws.amazon.com y crea una cuenta (tiene Free Tier)
2. En AWS Console → IAM → Users → Create User
3. Nombre: `paralelo-deploy`
4. Permisos: `AdministratorAccess` (para el proyecto)
5. Crear Access Key → tipo "CLI"
6. Guarda el `Access Key ID` y `Secret Access Key`

---

## Paso 3 — Crear el bucket S3 para el estado de Terraform

Solo se hace una vez, desde tu PC con AWS CLI:
```bash
aws configure   # ingresa tus credenciales
aws s3 mb s3://paralelo-terraform-state --region us-east-1
```

---

## Paso 4 — Configurar GitHub Secrets

En tu repositorio de GitHub:
**Settings → Secrets and variables → Actions → New repository secret**

Crea estos 5 secrets:

| Secret | Valor |
|--------|-------|
| `AWS_ACCESS_KEY_ID` | El Access Key ID de AWS |
| `AWS_SECRET_ACCESS_KEY` | El Secret Access Key de AWS |
| `AWS_REGION` | `us-east-1` |
| `DATABASE_URL` | La connection string de Neon |
| `JWT_SECRET` | `mi_clave_super_secreta_jwt_2024` |

---

## Paso 5 — Subir el proyecto a GitHub

```bash
git init
git add .
git commit -m "Initial commit — Paralelo API Serverless"
git branch -M main
git remote add origin https://github.com/TU_USUARIO/paralelo.git
git push -u origin main
```

El push dispara automáticamente el GitHub Actions pipeline.

---

## Paso 6 — Ver el pipeline en GitHub

1. Ve a tu repositorio en GitHub
2. Pestaña **Actions**
3. Verás el workflow corriendo con 2 jobs: `Build Go Lambda` y `Terraform Deploy`
4. Al terminar verás la URL del API Gateway en los logs:
   ```
   API Gateway URL:
   https://xxxxxxxxxxxx.execute-api.us-east-1.amazonaws.com
   ```

---

## Paso 7 — Actualizar la app Flutter

Abre `paralelo_app/lib/core/constants/api_constants.dart` y cambia:
```dart
const String kBaseUrl = 'https://xxxxxxxxxxxx.execute-api.us-east-1.amazonaws.com/api';
```

---

## Estructura de archivos

```
paralelo/                  ← Backend Go (ya existente)
paralelo_app/              ← App Flutter (ya existente)
terraform/
├── provider.tf            ← Configuración de AWS y backend S3
├── main.tf                ← Lambda, API Gateway, IAM, S3, CloudWatch
├── variables.tf           ← Variables (región, nombre, secretos)
├── outputs.tf             ← URL del API Gateway
└── terraform.tfvars       ← Valores no sensibles
.github/
└── workflows/
    └── deploy.yml         ← Pipeline CI/CD completo
```
