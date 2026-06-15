output "api_gateway_url" {
  description = "URL pública del API Gateway"
  value       = aws_apigatewayv2_api.main.api_endpoint
}

output "sns_topic_arn" {
  description = "ARN del SNS Topic de notificaciones"
  value       = aws_sns_topic.notifications.arn
}

output "sqs_queue_url" {
  description = "URL de la SQS Queue"
  value       = aws_sqs_queue.notifications.url
}

output "notification_lambda_name" {
  description = "Nombre de la Lambda de notificaciones"
  value       = aws_lambda_function.notification.function_name
}

output "s3_bucket_name" {
  description = "Bucket S3 para archivos"
  value       = aws_s3_bucket.uploads.bucket
}
