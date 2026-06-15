package handlers

import (
	"encoding/json"
	"fmt"
	"net/http"
	"os"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/sns"
	"github.com/gin-gonic/gin"
)

type NotificationRequest struct {
	Email   string `json:"email"   binding:"required"`
	Subject string `json:"subject" binding:"required"`
	Message string `json:"message" binding:"required"`
}

// SendNotification godoc
// POST /api/notifications/send
func SendNotification(c *gin.Context) {
	var req NotificationRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "email, subject y message son requeridos",
		})
		return
	}

	topicARN := os.Getenv("SNS_TOPIC_ARN")
	if topicARN == "" {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "SNS_TOPIC_ARN no configurado",
		})
		return
	}

	region := os.Getenv("AWS_SES_REGION")
	if region == "" {
		region = "us-east-1"
	}

	// Crear sesión AWS
	sess, err := session.NewSession(&aws.Config{
		Region: aws.String(region),
	})
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "Error conectando con AWS",
		})
		return
	}

	// Serializar el mensaje
	msgBytes, _ := json.Marshal(map[string]string{
		"email":   req.Email,
		"subject": req.Subject,
		"message": req.Message,
	})

	// Publicar en SNS
	snsClient := sns.New(sess)
	result, err := snsClient.Publish(&sns.PublishInput{
		TopicArn: aws.String(topicARN),
		Message:  aws.String(string(msgBytes)),
		Subject:  aws.String(req.Subject),
	})
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": fmt.Sprintf("Error publicando en SNS: %v", err),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message":    "Notificación enviada exitosamente",
		"message_id": *result.MessageId,
	})
}
