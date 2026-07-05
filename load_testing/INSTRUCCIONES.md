# Pruebas de Carga y Análisis de Rendimiento — Paralelo API

## 📋 Tabla de Contenidos
1. Instalación de k6
2. Obtener un JWT válido
3. Ejecutar cada prueba
4. Monitorear AWS CloudWatch en paralelo
5. Recolectar resultados
6. Análisis de resultados

---

## 1️⃣ Instalación de k6

### Windows
Opción A — Chocolatey (si lo tienes instalado):
```bash
choco install k6
```

Opción B — Descarga manual:
- Ve a https://github.com/grafana/k6/releases
- Descarga `k6-v0.x.x-windows-amd64.zip`
- Extrae en `C:\k6`
- Agrega `C:\k6` al PATH del sistema

Verifica:
```bash
k6 --version
```

---

## 2️⃣ Obtener un JWT válido

Antes de cualquier prueba, necesitas un token válido. Ejecuta:

```bash
curl -X POST https://wzz06dh10b.execute-api.us-east-1.amazonaws.com/api/auth/login \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"lauras@utesa.edu\",\"password\":\"123456\"}"
```

Te devolverá:
```json
{
  "token": "eyJhbGciOiJIUzI1NiIs...",
  "message": "Login exitoso"
}
```

Copia el token completo (sin comillas) y reemplázalo en cada script donde dice `TU_TOKEN_JWT_AQUI`.

---

## 3️⃣ Ejecutar las pruebas

### Prueba 1 — Línea Base (10 usuarios, 1 minuto)

```bash
cd C:\Users\laura\Desktop\UTESA\10mo cuatriestre\paralelo\paralelo1\paralelo\load_testing\scripts
k6 run 01_linea_base.js --out json=resultados/baseline.json
```

**Tiempo:** ~1 minuto

**Monitorea mientras corre:**
- AWS Console → CloudWatch → Logs Insights
- Busca el log group `/aws/lambda/paralelo-api`

### Prueba 2 — Incremento Progresivo (50, 100, 250, 500 usuarios)

```bash
k6 run 02_incremento_progresivo.js --out json=resultados/incremento.json
```

**Tiempo:** ~8 minutos (2 min × 4 escenarios)

**Espera a que termine completamente.** Registra en una hoja:

| Usuarios | Latencia promedio | P95 | P99 | Tasa errores | Throughput (req/s) |
|----------|------|-----|-----|-------------|----------|
| 50       | ?    | ?   | ?   | ?           | ?        |
| 100      | ?    | ?   | ?   | ?           | ?        |
| 250      | ?    | ?   | ?   | ?           | ?        |
| 500      | ?    | ?   | ?   | ?           | ?        |

Los valores saldrán en la terminal al final. Cópialos.

### Prueba 3 — Estrés (100, 250, 500, 750, 1000, 1500, 2000 usuarios)

```bash
k6 run 03_prueba_estres.js --out json=resultados/estres.json
```

**Tiempo:** ~7 minutos

**NOTA:** Esta prueba se detendrá automáticamente si:
- Errores > 5%
- P95 > 5 segundos
- Cualquier timeout de Lambda

Si se detiene antes, anota a cuántos usuarios ocurrió.

### Prueba 4 — Recuperación

```bash
k6 run 04_prueba_recuperacion.js --out json=resultados/recuperacion.json
```

**Tiempo:** ~6 minutos (2 min subida + 1 min pico + 3 min bajada)

---

## 4️⃣ Monitorear AWS CloudWatch EN PARALELO

Abre OTRA terminal mientras las pruebas corren:

```bash
# Terminal 1: ejecuta k6
k6 run 02_incremento_progresivo.js

# Terminal 2: abre AWS Console
# Ve a: CloudWatch → Logs Insights
```

Ejecuta estas queries en CloudWatch:

**Query 1 — Errores en Lambda:**
```sql
fields @timestamp, @message
| filter @message like /error/i or @message like /Error/i
| stats count() as errores by bin(5m)
```

**Query 2 — Duración de Lambda:**
```sql
fields @duration
| stats avg(@duration), max(@duration), pct(@duration, 95), pct(@duration, 99)
```

**Query 3 — Invocaciones por segundo:**
```sql
fields @timestamp
| stats count() as invocaciones by bin(10s)
```

---

## 5️⃣ Monitorear AWS Métricas (CloudWatch Metrics)

Abre AWS Console:

### API Gateway
Ve a: **CloudWatch → Metrics → API Gateway** → selecciona tu API
Mira gráficos de:
- **Count** (requests totales)
- **Latency** (tiempo promedio)
- **IntegrationLatency** (tiempo en Lambda)
- **4XXError, 5XXError** (errores)

### Lambda
Ve a: **CloudWatch → Metrics → Lambda** → selecciona `paralelo-api`
Mira:
- **Invocations** (cuántas veces se ejecutó)
- **Duration** (cuánto tardó cada una)
- **ConcurrentExecutions** (cuántas corrían al mismo tiempo)
- **Errors** (cuántas fallaron)

### SNS
Ve a: **CloudWatch → Metrics → SNS**
Mira:
- **NumberOfMessagesPublished** (cuántos mensajes publicó)

### SQS
Ve a: **CloudWatch → Metrics → SQS**
Mira:
- **NumberOfMessagesSent** (cuántos llegaron a la cola)
- **ApproximateNumberOfMessagesVisible** (cuántos quedan por procesar)

### notification-lambda
Ve a: **CloudWatch → Metrics → Lambda** → selecciona `paralelo-notification-lambda`
Mira:
- **Invocations** (cuántas se ejecutaron)
- **ConcurrentExecutions** (concurrencia)
- **Duration** (tiempo de envío de emails)
- **Errors** (errores al enviar)

---

## 6️⃣ Recolectar Resultados Finales

Al terminar todas las pruebas, crea un documento con:

### Resumen Línea Base (10 usuarios)
```
Tiempo promedio de respuesta: X ms
Tiempo mínimo: X ms
Tiempo máximo: X ms
Requests por segundo: X
Porcentaje de errores: X%
```

### Resumen Incremento Progresivo
(Tabla como la de arriba con los 4 escenarios)

### Resumen Prueba de Estrés
```
Punto de degradación alcanzado en: X usuarios
Última latencia registrada: X ms
Tasa de errores: X%
Throttles observados: SI/NO
```

### Resumen Recuperación
```
Tiempo para vaciar la SQS después de parar: X minutos
Tiempo de recuperación de Lambda: X minutos
Comportamiento CloudWatch: (descripción)
```

---

## 🔍 Interpretación de resultados

**P95 y P99:** Percentiles
- P95 = 95% de requests tardaron menos de esto
- P99 = 99% de requests tardaron menos de esto

**Throughput:** requests por segundo (mayor = mejor)

**Throttling:** cuando Lambda se queda sin recursos y empieza a rechazar requests

---

## ⚠️ Posibles problemas

**"Error: JWT expirado"**
→ Obtén uno nuevo ejecutando el login nuevamente

**"429 Too Many Requests"**
→ Bajaste demasiado los tiempos de espera o hay throttling en Lambda

**"Task timed out"**
→ Lambda se quedó sin concurrencia disponible

**La SQS no se vacía después de parar**
→ La notification-lambda podría estar en error. Revisa los logs en CloudWatch

---

## 📊 Análisis esperado

Si todo está bien configurado:
- Con 50 usuarios, latencia ~100-200ms
- Con 500 usuarios, latencia ~500-1000ms
- Punto de degradación entre 1000-2000 usuarios
- SQS debe vaciarse en menos de 5 minutos después de parar la prueba
