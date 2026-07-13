package router

import (
	"paralelo/internal/adapters/primary/http/handlers"
	"paralelo/internal/adapters/primary/http/middleware"

	"github.com/gin-gonic/gin"
)

func SetupRouter(userHandler *handlers.UserHandler) *gin.Engine {
	r := gin.Default()

	// CORS middleware
	r.Use(func(c *gin.Context) {
		c.Header("Access-Control-Allow-Origin", "*")
		c.Header("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
		c.Header("Access-Control-Allow-Headers", "Content-Type, Authorization")
		if c.Request.Method == "OPTIONS" {
			c.AbortWithStatus(204)
			return
		}
		c.Next()
	})

	r.Static("/uploads", "./uploads")

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
	api.POST("/notifications/send", middleware.AuthMiddleware(), handlers.SendNotification)

	return r
}
