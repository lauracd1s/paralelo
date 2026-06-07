package main

import (
	"context"
	"database/sql"
	"fmt"
	"log"
	"os"

	"paralelo/internal/adapters/primary/http/handlers"
	"paralelo/internal/adapters/primary/http/middleware"
	"paralelo/internal/adapters/secondary/postgres/repositories"
	"paralelo/internal/core/services"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	ginadapter "github.com/awslabs/aws-lambda-go-api-proxy/gin"
	"github.com/gin-gonic/gin"
	_ "github.com/lib/pq"
)

var ginLambda *ginadapter.GinLambda

func init() {
	gin.SetMode(gin.ReleaseMode)

	// Conectar a la base de datos cloud usando DATABASE_URL
	dbURL := os.Getenv("DATABASE_URL")
	if dbURL == "" {
		log.Fatal("DATABASE_URL no configurada")
	}

	db, err := sql.Open("postgres", dbURL)
	if err != nil {
		log.Fatalf("Error abriendo BD: %v", err)
	}
	if err := db.Ping(); err != nil {
		log.Fatalf("Error conectando BD: %v", err)
	}

	// Migración automática
	migrateDB(db)

	// Inyección de dependencias
	userRepo    := repositories.NewPostgresUserRepository(db)
	userService := services.NewUserService(userRepo)
	userHandler := handlers.NewUserHandler(userService)

	// Configurar Gin
	r := gin.Default()
	r.Static("/uploads", "/tmp/uploads")

	api := r.Group("/api")
	auth := api.Group("/auth")
	{
		auth.POST("/register", userHandler.Register)
		auth.POST("/login", userHandler.Login)
	}

	usuarios := api.Group("/usuarios")
	usuarios.Use(middleware.AuthMiddleware())
	{
		usuarios.GET("", userHandler.GetAll)
		usuarios.GET("/:id", userHandler.GetByID)
		usuarios.PUT("/:id", userHandler.Update)
		usuarios.DELETE("/:id", userHandler.Delete)
	}

	api.POST("/upload", middleware.AuthMiddleware(), handlers.Upload)

	ginLambda = ginadapter.New(r)
}

func Handler(ctx context.Context, req events.APIGatewayV2HTTPRequest) (events.APIGatewayV2HTTPResponse, error) {
	return ginLambda.ProxyWithContext(ctx, req)
}

func main() {
	lambda.Start(Handler)
}

func migrateDB(db *sql.DB) {
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
	if _, err := db.Exec(query); err != nil {
		log.Fatalf("Error en migración: %v", err)
	}
	fmt.Println("Migración completada")
}
