package database

import (
	"database/sql"
	"fmt"
	"log"
	"os"

	_ "github.com/lib/pq"
)

// Connect establece la conexión con PostgreSQL
func Connect() *sql.DB {
	dsn := fmt.Sprintf(
		"host=%s port=%s user=%s password=%s dbname=%s sslmode=%s",
		getEnv("DB_HOST", "localhost"),
		getEnv("DB_PORT", "5432"),
		getEnv("DB_USER", "postgres"),
		getEnv("DB_PASSWORD", "postgres"),
		getEnv("DB_NAME", "paralelo_db"),
		getEnv("DB_SSLMODE", "disable"),
	)

	db, err := sql.Open("postgres", dsn)
	if err != nil {
		log.Fatalf("Error al abrir la conexión con la BD: %v", err)
	}

	if err := db.Ping(); err != nil {
		log.Fatalf("No se pudo conectar a PostgreSQL: %v\nVerifica tus variables en .env", err)
	}

	log.Println("✅ Conexión a PostgreSQL establecida correctamente")
	return db
}

// Migrate crea las tablas si no existen
func Migrate(db *sql.DB) {
	query := `
	CREATE TABLE IF NOT EXISTS usuarios (
		id         SERIAL PRIMARY KEY,
		nombre     VARCHAR(100) NOT NULL,
		email      VARCHAR(150) NOT NULL UNIQUE,
		password   VARCHAR(255) NOT NULL,
		rol        VARCHAR(50)  NOT NULL DEFAULT 'usuario',
		created_at TIMESTAMP    NOT NULL DEFAULT NOW(),
		updated_at TIMESTAMP    NOT NULL DEFAULT NOW()
	);`

	_, err := db.Exec(query)
	if err != nil {
		log.Fatalf("Error al ejecutar migración: %v", err)
	}
	log.Println("✅ Migración ejecutada: tabla 'usuarios' lista")
}

func getEnv(key, fallback string) string {
	if val := os.Getenv(key); val != "" {
		return val
	}
	return fallback
}
