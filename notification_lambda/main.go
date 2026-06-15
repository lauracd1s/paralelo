package main

import (
	"context"
	"encoding/json"
	"fmt"
	"log"
	"os"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/ses"
)

// NotificationMessage es la estructura del mensaje que llega desde SNS → SQS
type NotificationMessage struct {
	Email   string `json:"email"`
	Subject string `json:"subject"`
	Message string `json:"message"`
}

// SNSWrapper envuelve el mensaje original cuando viene de SNS
type SNSWrapper struct {
	Type    string `json:"Type"`
	Message string `json:"Message"`
}

func handler(ctx context.Context, event events.SQSEvent) error {
	senderEmail := os.Getenv("SES_SENDER_EMAIL")
	region := os.Getenv("AWS_SES_REGION")
	if region == "" {
		region = "us-east-1"
	}

	sess, err := session.NewSession(&aws.Config{
		Region: aws.String(region),
	})
	if err != nil {
		return fmt.Errorf("error creando sesión AWS: %v", err)
	}

	sesClient := ses.New(sess)

	for _, record := range event.Records {
		log.Printf("Procesando mensaje SQS ID: %s", record.MessageId)

		// El mensaje de SQS viene envuelto por SNS
		var snsWrapper SNSWrapper
		if err := json.Unmarshal([]byte(record.Body), &snsWrapper); err != nil {
			log.Printf("Error parseando wrapper SNS: %v", err)
			continue
		}

		// El mensaje real está en el campo Message del wrapper
		var notification NotificationMessage
		if err := json.Unmarshal([]byte(snsWrapper.Message), &notification); err != nil {
			log.Printf("Error parseando notificación: %v", err)
			continue
		}

		log.Printf("Enviando email a: %s | Asunto: %s", notification.Email, notification.Subject)

		// Enviar email con AWS SES
		input := &ses.SendEmailInput{
			Destination: &ses.Destination{
				ToAddresses: []*string{aws.String(notification.Email)},
			},
			Message: &ses.Message{
				Body: &ses.Body{
					Text: &ses.Content{
						Charset: aws.String("UTF-8"),
						Data:    aws.String(notification.Message),
					},
					Html: &ses.Content{
						Charset: aws.String("UTF-8"),
						Data: aws.String(fmt.Sprintf(`
							<html>
							<body style="font-family: Arial, sans-serif; padding: 20px;">
								<h2 style="color: #7C6FCD;">%s</h2>
								<p>%s</p>
								<hr>
								<small style="color: #999;">Enviado desde Paralelo API — UTESA</small>
							</body>
							</html>
						`, notification.Subject, notification.Message)),
					},
				},
				Subject: &ses.Content{
					Charset: aws.String("UTF-8"),
					Data:    aws.String(notification.Subject),
				},
			},
			Source: aws.String(senderEmail),
		}

		result, err := sesClient.SendEmail(input)
		if err != nil {
			log.Printf("Error enviando email: %v", err)
			return err
		}

		log.Printf("✅ Email enviado exitosamente. MessageID: %s", *result.MessageId)
	}

	return nil
}

func main() {
	lambda.Start(handler)
}
