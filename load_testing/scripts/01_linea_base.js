import http from 'k6/http';
import { check, sleep } from 'k6';

// REEMPLAZA ESTO CON TU URL REAL
const API_URL = 'https://wzz06dh10b.execute-api.us-east-1.amazonaws.com';
const JWT_TOKEN = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJlbWFpbCI6InRlc3RAdGVzdC5jb20iLCJleHAiOjE3ODIxODU0MDAsImlhdCI6MTc4MjA5OTAwMCwicm9sIjoidXN1YXJpbyIsInN1YiI6NX0.6UYdDQxgipe75epm5ExoacKLo76JtgHpXCoZIcWzcPs'; // Obtén un token válido primero

export const options = {
  stages: [
    { duration: '1m', target: 10 }, // 1 minuto con 10 usuarios
  ],
  thresholds: {
    http_req_duration: ['p(95)<1000', 'p(99)<3000'], // P95 < 1s, P99 < 3s
    http_req_failed: ['rate<0.1'], // menos del 10% de errores
  },
};

export default function () {
  const payload = JSON.stringify({
    email: 'test@test.com',
    subject: 'Prueba de carga',
    message: 'Este es un mensaje de prueba de carga',
  });

  const params = {
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${JWT_TOKEN}`,
    },
  };

  const res = http.post(`${API_URL}/api/notifications/send`, payload, params);

  check(res, {
    'status es 200': (r) => r.status === 200,
    'tiempo de respuesta < 1s': (r) => r.timings.duration < 1000,
    'no hay errores': (r) => r.body && !r.body.includes('error'),
  });

  sleep(1); // espera 1 segundo entre requests
}
