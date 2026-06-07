variable "aws_region" {
  description = "Región de AWS"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Nombre del proyecto"
  type        = string
  default     = "paralelo"
}

variable "environment" {
  description = "Ambiente (prod, dev)"
  type        = string
  default     = "prod"
}

variable "jwt_secret" {
  description = "Clave secreta para JWT"
  type        = string
  sensitive   = true
}

variable "database_url" {
  description = "URL de conexión a la base de datos cloud"
  type        = string
  sensitive   = true
}

variable "lambda_zip_path" {
  description = "Ruta al ZIP del binario de la Lambda"
  type        = string
  default     = "../lambda/function.zip"
}
