package handlers

import (
	"fmt"
	"net/http"
	"os"
	"path/filepath"
	"time"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/s3"
	"github.com/gin-gonic/gin"
)

func Upload(c *gin.Context) {
	file, err := c.FormFile("file")
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "No se recibió ningún archivo"})
		return
	}

	ext := filepath.Ext(file.Filename)
	filename := fmt.Sprintf("%d%s", time.Now().UnixNano(), ext)

	src, err := file.Open()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Error al leer el archivo"})
		return
	}
	defer src.Close()

	bucket := os.Getenv("S3_BUCKET")

	if bucket != "" {
		region := os.Getenv("AWS_S3_REGION")
		if region == "" {
			region = "us-east-1"
		}

		sess, err := session.NewSession(&aws.Config{
			Region: aws.String(region),
		})
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Error al conectar con S3"})
			return
		}

		svc := s3.New(sess)
		_, err = svc.PutObject(&s3.PutObjectInput{
			Bucket:      aws.String(bucket),
			Key:         aws.String("uploads/" + filename),
			Body:        src,
			ContentType: aws.String(file.Header.Get("Content-Type")),
			// Sin ACL — bucket usa Object Ownership por defecto
		})
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Error al subir a S3: " + err.Error()})
			return
		}

		fileURL := fmt.Sprintf("https://%s.s3.%s.amazonaws.com/uploads/%s", bucket, region, filename)
		c.JSON(http.StatusOK, gin.H{
			"message":  "Archivo subido exitosamente a S3",
			"filename": filename,
			"url":      fileURL,
			"size":     file.Size,
		})
		return
	}

	// Modo local
	uploadDir := "/tmp/uploads"
	os.MkdirAll(uploadDir, os.ModePerm)
	savePath := filepath.Join(uploadDir, filename)
	if err := c.SaveUploadedFile(file, savePath); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Error al guardar el archivo"})
		return
	}

	host := c.Request.Host
	fileURL := fmt.Sprintf("http://%s/uploads/%s", host, filename)
	c.JSON(http.StatusOK, gin.H{
		"message":  "Archivo subido exitosamente",
		"filename": filename,
		"url":      fileURL,
		"size":     file.Size,
	})
}
