package main

import (
	"log"
	"os"

	"paralelo/internal/adapters/primary/http/handlers"
	"paralelo/internal/adapters/primary/http/router"
	"paralelo/internal/adapters/secondary/postgres/repositories"
	"paralelo/internal/core/services"
	"paralelo/internal/infrastructure/database"

	"github.com/joho/godotenv"
)

func main() {
	// Cargar variables de entorno desde .env
	if err := godotenv.Load(); err != nil {
		log.Println("⚠️  Archivo .env no encontrado, usando variables del sistema")
	}

	// 1. Conectar a la base de datos (infraestructura)
	db := database.Connect()
	defer db.Close()

	// 2. Ejecutar migraciones
	database.Migrate(db)

	// 3. Inyección de dependencias (Arquitectura Hexagonal)
	//    Secundario: repositorio PostgreSQL (adaptador)
	userRepo := repositories.NewPostgresUserRepository(db)

	//    Core: servicio con la lógica de negocio
	userService := services.NewUserService(userRepo)

	//    Primario: handler HTTP (adaptador)
	userHandler := handlers.NewUserHandler(userService)

	// 4. Configurar rutas
	r := router.SetupRouter(userHandler)

	// 5. Arrancar el servidor
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	log.Printf("🚀 Servidor corriendo en http://localhost:%s", port)
	if err := r.Run(":" + port); err != nil {
		log.Fatalf("Error al iniciar el servidor: %v", err)
	}
}
