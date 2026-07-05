# 🚀 Pruebas de Carga y Análisis de Rendimiento — Paralelo API

Este directorio contiene todo lo necesario para evaluar el comportamiento y escalabilidad de tu arquitectura serverless en AWS.

---

## 📁 Estructura del Proyecto

```
load_testing/
├── scripts/
│   ├── 01_linea_base.js              ← Prueba con 10 usuarios
│   ├── 02_incremento_progresivo.js   ← 50, 100, 250, 500 usuarios
│   ├── 03_prueba_estres.js           ← Encuentra punto de degradación
│   └── 04_prueba_recuperacion.js     ← Mide capacidad de recuperación
├── resultados/                        ← Se guardan aquí los JSON de k6
├── INSTRUCCIONES.md                   ← Guía paso a paso (LEEME PRIMERO)
├── TEMPLATE_RESULTADOS.md             ← Plantilla para reportar
└── analizar_resultados.py             ← Script para analizar JSON
```

---

## 🎯 Qué midas en cada prueba

### 1️⃣ Línea Base (10 usuarios, 1 minuto)
**Objetivo:** Establecer el comportamiento normal del sistema

Medir:
- ✅ Tiempo promedio de respuesta
- ✅ Tiempo mínimo y máximo
- ✅ Requests por segundo
- ✅ Porcentaje de errores

**Archivo:** `scripts/01_linea_base.js`

### 2️⃣ Incremento Progresivo (50→100→250→500 usuarios)
**Objetivo:** Ver cómo degrada el rendimiento conforme crece la carga

Medir para cada escenario:
- ✅ Throughput (req/s)
- ✅ Latencia promedio
- ✅ P95 y P99
- ✅ Tasa de errores

**Archivo:** `scripts/02_incremento_progresivo.js`

### 3️⃣ Monitoreo AWS
**Objetivo:** Entender qué está pasando en cada servicio

Monitorea en tiempo real:
- **API Gateway:** Count, Latency, Errors
- **Lambda principal:** Invocations, Duration, Concurrent Executions
- **SNS:** MessagePublished
- **SQS:** Messages visible en la cola
- **notification-Lambda:** Ejecuciones y errores
- **CloudWatch:** Logs

**Herramienta:** AWS Console → CloudWatch

### 4️⃣ Prueba de Estrés (100→2000 usuarios)
**Objetivo:** Encontrar dónde colapsa el sistema

Ejecuta hasta que ocurra:
- ❌ >5% de errores
- ❌ Latencia >5 segundos
- ❌ Throttling en Lambda
- ❌ SQS completamente saturada

**Archivo:** `scripts/03_prueba_estres.js`

### 5️⃣ Recuperación (500 usuarios, luego parada)
**Objetivo:** Medir qué tan rápido se recupera de una carga alta

Medir después de parar:
- ✅ Tiempo para vaciar SQS completamente
- ✅ Tiempo para que Lambda vuelva a 0
- ✅ Tiempo para que desaparezcan errores
- ✅ Comportamiento natural de recuperación

**Archivo:** `scripts/04_prueba_recuperacion.js`

---

## ⚙️ Primeros Pasos

### Paso 1 — Instalar k6
```bash
# Windows con Chocolatey
choco install k6

# O descarga manual
# https://github.com/grafana/k6/releases

# Verifica
k6 --version
```

### Paso 2 — Obtener JWT válido
```bash
curl -X POST https://wzz06dh10b.execute-api.us-east-1.amazonaws.com/api/auth/login \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"lauras@utesa.edu\",\"password\":\"123456\"}"
```

Copia el `token` que devuelve.

### Paso 3 — Actualizar scripts con tu token y URL
Edita cada archivo `.js` y reemplaza:
```javascript
const JWT_TOKEN = 'eyJhbGciOiJIUzI1NiIs...'; // pega tu token aquí
```

### Paso 4 — Ejecutar pruebas
```bash
cd load_testing/scripts

# Prueba 1 — Línea base (~1 min)
k6 run 01_linea_base.js --out json=../resultados/baseline.json

# Prueba 2 — Incremento (~8 min)
k6 run 02_incremento_progresivo.js --out json=../resultados/incremento.json

# Prueba 3 — Estrés (~7 min, puede terminar antes)
k6 run 03_prueba_estres.js --out json=../resultados/estres.json

# Prueba 4 — Recuperación (~6 min)
k6 run 04_prueba_recuperacion.js --out json=../resultados/recuperacion.json
```

---

## 📊 Interpretar Resultados

### Métricas clave de k6

**Throughput:** Requests por segundo (cuantas peticiones procesa por segundo)
- Ejemplo: 100 req/s significa que el sistema puede manejar 100 peticiones/segundo
- Mayor = mejor

**Latencia:** Tiempo que tarda en responder (en milisegundos)
- P95 = 95% de requests tardaron menos de esto
- P99 = 99% de requests tardaron menos de esto
- Menor = mejor

**Error Rate:** Porcentaje de requests que fallaron
- 0% = nada falló
- 5% = 1 de cada 20 falló
- Menor = mejor

**Concurrent Executions:** Cuántas Lambdas corrieron al mismo tiempo
- Límite por defecto en AWS: 1000 per región
- Si llegas al límite, AWS rechaza más requests

---

## 🔍 Analizar Resultados JSON

Después de cada prueba, k6 genera un archivo JSON. Para analizarlo:

```bash
# Opción 1 — Con el script Python
cd load_testing
python analizar_resultados.py resultados/baseline.json

# Opción 2 — Instalar herramienta web de k6
npm install -g @grafana/k6-to-html
k6 run --out json=resultados/baseline.json scripts/01_linea_base.js
# Luego abre resultados/baseline.html en el navegador
```

---

## 🎓 Interpretación de Resultados Esperados

### Sistema saludable
- P95 latencia: < 500ms
- P99 latencia: < 1000ms
- Error rate: < 1%
- Throughput: > 100 req/s

### Degradación observable
- P95 latencia: 500-2000ms
- Error rate: 1-5%
- Algunos timeouts ocasionales

### Sistema colapsado
- P95 latencia: > 5000ms
- Error rate: > 5%
- Muchos 503 Service Unavailable
- Throttling en Lambda

---

## 📈 Monitorear AWS durante Pruebas

Abre DOS terminales:

**Terminal 1 — Ejecuta k6:**
```bash
k6 run scripts/02_incremento_progresivo.js
```

**Terminal 2 — Monitorea AWS (en paralelo):**
1. Abre AWS Console en navegador
2. Ve a CloudWatch → Metrics
3. Abre gráficos de:
   - API Gateway (Count, Latency)
   - Lambda (Invocations, Duration, Concurrent)
   - SQS (Messages Visible)

**Terminal 3 — Ver logs en vivo:**
```bash
# CloudWatch Logs Insights
# Ve a: CloudWatch → Logs Insights
# Ejecuta esta query:

fields @timestamp, @message, @duration
| stats count() as invocaciones, 
        avg(@duration) as latencia_promedio,
        max(@duration) as latencia_maxima
        by bin(10s)
```

---

## 📝 Documentar Resultados

Usa la plantilla `TEMPLATE_RESULTADOS.md` para documentar:
1. Copiar valores de las métricas k6
2. Tomar screenshots de CloudWatch
3. Anotar observaciones
4. Proponer mejoras

---

## ⚡ Optimizaciones basadas en resultados

Si el punto de degradación está muy bajo (< 500 usuarios):

**Aumentar memoria de Lambda:**
```bash
aws lambda update-function-configuration \
  --function-name paralelo-api \
  --memory-size 512 \
  --region us-east-1
```

**Aumentar concurrencia reservada:**
```bash
aws lambda put-function-concurrency \
  --function-name paralelo-api \
  --reserved-concurrent-executions 1000 \
  --region us-east-1
```

**Aumentar visibilidad de SQS:**
```bash
aws sqs set-queue-attributes \
  --queue-url https://sqs.us-east-1.amazonaws.com/xxx/paralelo-notifications-queue \
  --attributes ReceiveMessageWaitTimeSeconds=20 \
  --region us-east-1
```

---

## 🆘 Problemas comunes

**"Error: Invalid token"**
→ El JWT expiró. Obtén uno nuevo con el login.

**"429 Too Many Requests"**
→ Bajaste demasiado los delays (`sleep`). Aumenta a 1-2 segundos.

**"Task timed out"**
→ Lambda se quedó sin concurrencia. Aumenta memory o reserved concurrency.

**"SQS no se vacía"**
→ notification-lambda está en error. Revisa CloudWatch Logs.

---

## 📞 Apoyo

Si tienes dudas sobre:
- **k6:** https://k6.io/docs/
- **AWS CloudWatch:** https://docs.aws.amazon.com/cloudwatch/
- **Este proyecto:** Ve a INSTRUCCIONES.md

---

## ✅ Checklist antes de entregar

- ✅ Todas las 5 pruebas ejecutadas
- ✅ JSON de resultados guardados en `resultados/`
- ✅ Template completado con métricas
- ✅ Screenshots de CloudWatch adjuntos
- ✅ Análisis y conclusiones escritas
- ✅ Recomendaciones de mejora listadas
