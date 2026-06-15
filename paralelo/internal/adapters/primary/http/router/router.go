package router

import (
	"paralelo/internal/adapters/primary/http/handlers"
	"paralelo/internal/adapters/primary/http/middleware"

	"github.com/gin-gonic/gin"
)

func SetupRouter(userHandler *handlers.UserHandler) *gin.Engine {
	r := gin.Default()

	r.Static("/uploads", "./uploads")

	api := r.Group("/api")

	// Rutas públicas
	auth := api.Group("/auth")
	{
		auth.POST("/register", userHandler.Register)
		auth.POST("/login", userHandler.Login)
	}

	// Rutas protegidas — CRUD usuarios
	usuarios := api.Group("/usuarios")
	usuarios.Use(middleware.AuthMiddleware())
	{
		usuarios.GET("", userHandler.GetAll)
		usuarios.GET("/:id", userHandler.GetByID)
		usuarios.PUT("/:id", userHandler.Update)
		usuarios.DELETE("/:id", userHandler.Delete)
	}

	// Upload de archivos
	api.POST("/upload", middleware.AuthMiddleware(), handlers.Upload)

	// Notificaciones SNS
	api.POST("/notifications/send", middleware.AuthMiddleware(), handlers.SendNotification)

	return r
}
