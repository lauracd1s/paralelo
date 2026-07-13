-- Script para crear la base de datos y tabla
-- Ejecutar en psql o pgAdmin antes de correr la API



CREATE TABLE IF NOT EXISTS usuarios (
    id         SERIAL PRIMARY KEY,
    nombre     VARCHAR(100) NOT NULL,
    email      VARCHAR(150) NOT NULL UNIQUE,
    password   VARCHAR(255) NOT NULL,
    rol        VARCHAR(50)  NOT NULL DEFAULT 'usuario',
    created_at TIMESTAMP    NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP    NOT NULL DEFAULT NOW()
);

-- Índice en email para búsquedas rápidas
CREATE INDEX IF NOT EXISTS idx_usuarios_email ON usuarios(email);

-- Datos de ejemplo (opcional)
-- La contraseña es: "admin123" hasheada con bcrypt
INSERT INTO usuarios (nombre, email, password, rol)
VALUES (
    'Admin',
    'admin@paralelo.com',
    '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy',
    'admin'
) ON CONFLICT DO NOTHING;
