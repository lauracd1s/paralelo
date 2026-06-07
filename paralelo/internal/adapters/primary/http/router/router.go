package router

import (
	"paralelo/internal/adapters/primary/http/handlers"
	"paralelo/internal/adapters/primary/http/middleware"

	"github.com/gin-gonic/gin"
)

func SetupRouter(userHandler *handlers.UserHandler) *gin.Engine {
	r := gin.Default()

	// Servir archivos estáticos subidos
	r.Static("/uploads", "./uploads")

	api := r.Group("/api")

	// Rutas públicas
	auth := api.Group("/auth")
	{
		auth.POST("/register", userHandler.Register)
		auth.POST("/login", userHandler.Login)
	}

	// Rutas protegidas
	usuarios := api.Group("/usuarios")
	usuarios.Use(middleware.AuthMiddleware())
	{
		usuarios.GET("", userHandler.GetAll)
		usuarios.GET("/:id", userHandler.GetByID)
		usuarios.PUT("/:id", userHandler.Update)
		usuarios.DELETE("/:id", userHandler.Delete)
	}

	// Upload de archivos (protegido)
	api.POST("/upload", middleware.AuthMiddleware(), handlers.Upload)

	return r
}
