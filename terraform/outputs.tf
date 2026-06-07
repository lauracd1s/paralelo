output "api_gateway_url" {
  description = "URL pública del API Gateway — úsala en la app Flutter"
  value       = aws_apigatewayv2_api.main.api_endpoint
}

output "lambda_function_name" {
  description = "Nombre de la función Lambda"
  value       = aws_lambda_function.api.function_name
}

output "s3_bucket_name" {
  description = "Bucket S3 para archivos subidos"
  value       = aws_s3_bucket.uploads.bucket
}

output "s3_bucket_url" {
  description = "URL base del bucket S3"
  value       = "https://${aws_s3_bucket.uploads.bucket}.s3.${var.aws_region}.amazonaws.com"
}
