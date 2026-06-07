package main

import (
	"context"
	"log"
	"os"

	"paralelo/internal/adapters/primary/http/handlers"
	"paralelo/internal/adapters/primary/http/router"
	"paralelo/internal/adapters/secondary/postgres/repositories"
	"paralelo/internal/core/services"
	"paralelo/internal/infrastructure/database"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	ginadapter "github.com/awslabs/aws-lambda-go-api-proxy/gin"
	"github.com/gin-gonic/gin"
	"github.com/joho/godotenv"
)

var ginLambda *ginadapter.GinLambda

func buildRouter() *gin.Engine {
	db := database.Connect()
	database.Migrate(db)

	userRepo    := repositories.NewPostgresUserRepository(db)
	userService := services.NewUserService(userRepo)
	userHandler := handlers.NewUserHandler(userService)

	return router.SetupRouter(userHandler)
}

func lambdaHandler(ctx context.Context, req events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {
	return ginLambda.ProxyWithContext(ctx, req)
}

func main() {
	godotenv.Load()

	r := buildRouter()

	if os.Getenv("AWS_LAMBDA_FUNCTION_NAME") != "" {
		log.Println("Corriendo en modo Lambda")
		ginLambda = ginadapter.New(r)
		lambda.Start(lambdaHandler)
		return
	}

	// Modo local
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}
	log.Printf("🚀 Servidor corriendo en http://localhost:%s", port)
	r.Run(":" + port)
}
