import http from 'k6/http';
import { check, sleep } from 'k6';

const API_URL = 'https://wzz06dh10b.execute-api.us-east-1.amazonaws.com';
const JWT_TOKEN = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJlbWFpbCI6InRlc3RAdGVzdC5jb20iLCJleHAiOjE3ODIxODU0MDAsImlhdCI6MTc4MjA5OTAwMCwicm9sIjoidXN1YXJpbyIsInN1YiI6NX0.6UYdDQxgipe75epm5ExoacKLo76JtgHpXCoZIcWzcPs';

export const options = {
  stages: [
    { duration: '1m', target: 100 },
    { duration: '1m', target: 250 },
    { duration: '1m', target: 500 },
    { duration: '1m', target: 750 },
    { duration: '1m', target: 1000 },
    { duration: '1m', target: 1500 },
    { duration: '1m', target: 2000 },
  ],
  thresholds: {
    http_req_duration: ['p(95)<5000'], // alerta si P95 > 5s
    http_req_failed: ['rate<0.05'],    // alerta si errores > 5%
  },
};

export default function () {
  const payload = JSON.stringify({
    email: `stress_test_${__VU}_${__ITER}@test.com`,
    subject: `Stress Test - Usuarios: ${__VU}`,
    message: `Iteración ${__ITER} - Load Test de estrés`,
  });

  const params = {
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${JWT_TOKEN}`,
    },
  };

  const res = http.post(`${API_URL}/api/notifications/send`, payload, params);

  check(res, {
    'status 200': (r) => r.status === 200,
    'latencia < 5s': (r) => r.timings.duration < 5000,
    'sin errores': (r) => !r.body.includes('error'),
  });

  sleep(0.5); // menos espera para simular mayor estrés
}
