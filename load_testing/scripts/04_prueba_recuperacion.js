import http from 'k6/http';
import { check, sleep } from 'k6';

const API_URL = 'https://wzz06dh10b.execute-api.us-east-1.amazonaws.com';
const JWT_TOKEN = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJlbWFpbCI6InRlc3RAdGVzdC5jb20iLCJleHAiOjE3ODIxODU0MDAsImlhdCI6MTc4MjA5OTAwMCwicm9sIjoidXN1YXJpbyIsInN1YiI6NX0.6UYdDQxgipe75epm5ExoacKLo76JtgHpXCoZIcWzcPs';

export const options = {
  stages: [
    { duration: '2m', target: 500 },   // sube a 500 usuarios
    { duration: '1m', target: 500 },   // mantén 500 por 1 minuto
    { duration: '3m', target: 0 },     // baja a 0 progresivamente en 3 minutos
  ],
  thresholds: {
    http_req_duration: ['p(95)<2000'],
    http_req_failed: ['rate<0.1'],
  },
};

export default function () {
  const payload = JSON.stringify({
    email: `recovery_test_${__VU}@test.com`,
    subject: `Recovery Test - ${new Date().toISOString()}`,
    message: `Prueba de recuperación - Usuario ${__VU}`,
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
  });

  sleep(1);
}
