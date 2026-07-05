# 📊 Resultados de Pruebas de Carga — Paralelo API

**Fecha:** _______________  
**Ejecutado por:** _______________  
**URL API:** https://wzz06dh10b.execute-api.us-east-1.amazonaws.com  

---

## ✅ Actividad 1: Línea Base

**Configuración:**
- Usuarios virtuales: 10
- Duración: 1 minuto
- Endpoint: `POST /api/notifications/send`

**Resultados:**

| Métrica | Valor |
|---------|-------|
| Tiempo promedio de respuesta | _____ ms |
| Tiempo mínimo | _____ ms |
| Tiempo máximo | _____ ms |
| Requests por segundo | _____ req/s |
| Porcentaje de errores | _____ % |
| Total requests exitosas | _____ |
| Total requests fallidas | _____ |

**Observaciones:**

---

## ✅ Actividad 2: Incremento Progresivo

**Configuración:**
- Duración por escenario: 2 minutos cada uno
- Escenarios: 50, 100, 250, 500 usuarios

**Resultados por escenario:**

### Escenario 1: 50 usuarios

| Métrica | Valor |
|---------|-------|
| Throughput (req/s) | _____ |
| Latencia promedio | _____ ms |
| P95 | _____ ms |
| P99 | _____ ms |
| Tasa de errores | _____ % |
| Máximas ejecuciones concurrentes | _____ |

### Escenario 2: 100 usuarios

| Métrica | Valor |
|---------|-------|
| Throughput (req/s) | _____ |
| Latencia promedio | _____ ms |
| P95 | _____ ms |
| P99 | _____ ms |
| Tasa de errores | _____ % |
| Máximas ejecuciones concurrentes | _____ |

### Escenario 3: 250 usuarios

| Métrica | Valor |
|---------|-------|
| Throughput (req/s) | _____ |
| Latencia promedio | _____ ms |
| P95 | _____ ms |
| P99 | _____ ms |
| Tasa de errores | _____ % |
| Máximas ejecuciones concurrentes | _____ |

### Escenario 4: 500 usuarios

| Métrica | Valor |
|---------|-------|
| Throughput (req/s) | _____ |
| Latencia promedio | _____ ms |
| P95 | _____ ms |
| P99 | _____ ms |
| Tasa de errores | _____ % |
| Máximas ejecuciones concurrentes | _____ |

**Gráfico esperado:**
(Pega aquí un screenshot de k6 mostrando la curva de carga)

---

## ✅ Actividad 3: Monitoreo AWS

**Durante las pruebas se observó:**

### API Gateway Metrics
- Request Count máximo: _____ req/s
- Average Latency: _____ ms
- Integration Latency: _____ ms
- Error Rate: _____ %

**Screenshot:**
(Pega aquí image de CloudWatch)

### Lambda Principal (paralelo-api) Metrics
- Total Invocations: _____
- Average Duration: _____ ms
- Max Duration: _____ ms
- Concurrent Executions máximo: _____
- Errors: _____
- Throttles: _____

### SNS Metrics
- NumberOfMessagesPublished: _____

### SQS Metrics
- NumberOfMessagesSent: _____
- ApproximateNumberOfMessagesVisible (pico): _____

### Notification Lambda Metrics
- Total Invocations: _____
- Average Duration: _____ ms
- Concurrent Executions máximo: _____
- Errors: _____
- Throttles: _____

### CloudWatch Logs Analysis

**Errores registrados:**
```
(copia aquí los errores relevantes de CloudWatch Logs)
```

**Patrón de latencia:**
(Describe qué observaste en los logs)

---

## ✅ Actividad 4: Prueba de Estrés

**Configuración:**
- Usuarios iniciales: 100
- Incremento: 100, 250, 500, 750, 1000, 1500, 2000
- Duración por escalón: 1 minuto

**Punto de degradación:**

| Métrica | Valor |
|---------|-------|
| Usuarios en el punto de degradación | _____ |
| Latencia cuando se alcanzó | _____ ms |
| Tasa de errores en degradación | _____ % |
| Evento que causó parada | ☐ >5% errores ☐ Latencia >5s ☐ Throttling ☐ SQS saturada |
| Tiempo en que ocurrió | _____ minutos |

**Gráfico de estrés:**
(Pega screenshot de k6 mostrando dónde falló)

**Comportamiento de Lambda:**
- Máximas ejecuciones concurrentes alcanzadas: _____
- ¿Se observó throttling? SI / NO
- Errores de "Task timed out": _____

**Comportamiento de SQS:**
- Mensajes máximos en cola: _____
- ¿Se saturó la cola? SI / NO

---

## ✅ Actividad 5: Prueba de Recuperación

**Configuración:**
- Fase 1: Escalar a 500 usuarios en 2 minutos
- Fase 2: Mantener 500 usuarios por 1 minuto
- Fase 3: Bajar a 0 en 3 minutos

**Tiempos de recuperación:**

| Métrica | Tiempo |
|---------|--------|
| Tiempo para que SQS se vacíe completamente | _____ minutos |
| Tiempo para que Lambda vuelva a 0 ejecuciones | _____ minutos |
| Tiempo para que desaparezcan los errores | _____ minutos |
| Último mensaje procesado en | _____ minutos (después de parada) |

**Comportamiento observado:**

1. **Mientras bajaba la carga (0-3 minutos):**
   (Describe qué pasaba)

2. **Después de que paró completamente (3+ minutos):**
   - SQS continuó procesando? SI / NO
   - Hubo picos de latencia? SI / NO
   - Se recuperó naturalmente? SI / NO

**CloudWatch durante recuperación:**
(Pega screenshot mostrando la curva de recuperación)

---

## 📈 Análisis General y Conclusiones

### Capacidad del sistema
- **Throughput máximo sostenible:** _____ requests/segundo
- **Usuarios simultáneos máximos:** _____ (antes de degradación)
- **Latencia aceptable:** _____ ms (cuando el sistema está sano)

### Puntos fuertes
1. _____
2. _____
3. _____

### Puntos débiles / Problemas encontrados
1. _____
2. _____
3. _____

### Recomendaciones de mejora
1. Aumentar memoria de Lambda a _____ MB (actual: 256)
2. Considerar caching en API Gateway
3. Revisar concurrencia de SQS (actual: 1)
4. Otro: _____

### Conclusión final
(Escribe tu análisis general aquí)

---

## 📎 Archivos de soporte

**JSON de resultados k6:**
- `resultados/baseline.json`
- `resultados/incremento.json`
- `resultados/estres.json`
- `resultados/recuperacion.json`

**Logs CloudWatch:**
(Copia los ARNs de los log groups aquí)
- `/aws/lambda/paralelo-api`
- `/aws/lambda/paralelo-notification-lambda`

---

**Entregado:** _______________
