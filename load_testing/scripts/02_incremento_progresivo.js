import http from 'k6/http';
import { check, sleep } from 'k6';

const API_URL = 'https://wzz06dh10b.execute-api.us-east-1.amazonaws.com';
const JWT_TOKEN = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJlbWFpbCI6InRlc3RAdGVzdC5jb20iLCJleHAiOjE3ODIxODU0MDAsImlhdCI6MTc4MjA5OTAwMCwicm9sIjoidXN1YXJpbyIsInN1YiI6NX0.6UYdDQxgipe75epm5ExoacKLo76JtgHpXCoZIcWzcPs';

export const options = {
  stages: [
    { duration: '2m', target: 50 },    // 2 min escalando a 50 usuarios
    { duration: '2m', target: 100 },   // 2 min escalando a 100
    { duration: '2m', target: 250 },   // 2 min escalando a 250
    { duration: '2m', target: 500 },   // 2 min con 500
  ],
  thresholds: {
    http_req_duration: ['p(95)<2000', 'p(99)<5000'],
    http_req_failed: ['rate<0.05'], // máximo 5% de errores
  },
};

export default function () {
  const payload = JSON.stringify({
    email: `test_${__VU}@test.com`, // usuario virtual diferente por cada usuario
    subject: `Prueba Carga ${__ITER}`,
    message: `Mensaje iteración ${__ITER} desde usuario ${__VU}`,
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
    'P95 < 2s': (r) => r.timings.duration < 2000,
    'sin errores': (r) => !r.body.includes('error'),
  });

  sleep(1);
}
