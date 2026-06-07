package main

import (
	"log"
	"os"

	"paralelo/internal/adapters/primary/http/handlers"
	"paralelo/internal/adapters/primary/http/middleware"
	"paralelo/internal/adapters/primary/http/router"
	"paralelo/internal/adapters/secondary/postgres/repositories"
	"paralelo/internal/core/services"
	"paralelo/internal/infrastructure/database"

	"github.com/joho/godotenv"

	// Adaptador Lambda — solo activo cuando se compila con la tag lambda
	"context"
	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	ginadapter "github.com/awslabs/aws-lambda-go-api-proxy/gin"
	"github.com/gin-gonic/gin"
)

func buildRouter() *gin.Engine {
	db := database.Connect()
	database.Migrate(db)

	userRepo    := repositories.NewPostgresUserRepository(db)
	userService := services.NewUserService(userRepo)
	userHandler := handlers.NewUserHandler(userService)

	return router.SetupRouter(userHandler)
}

func main() {
	godotenv.Load()

	// Si hay variable AWS_LAMBDA_FUNCTION_NAME, estamos en Lambda
	if os.Getenv("AWS_LAMBDA_FUNCTION_NAME") != "" {
		log.Println("Corriendo en modo Lambda")
		r := buildRouter()
		ginLambda := ginadapter.New(r)

		lambda.Start(func(ctx context.Context, req events.APIGatewayV2HTTPRequest) (events.APIGatewayV2HTTPResponse, error) {
			return ginLambda.ProxyWithContext(ctx, req)
		})
		return
	}

	// Modo local normal
	r := buildRouter()
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}
	log.Printf("🚀 Servidor corriendo en http://localhost:%s", port)
	r.Run(":" + port)
}
