# ─────────────────────────────────────────
# IAM Role para Lambda principal (ya existe, solo agregamos política SNS)
# ─────────────────────────────────────────
resource "aws_iam_role_policy" "lambda_sns" {
  name = "${var.project_name}-lambda-sns-policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["sns:Publish"]
      Resource = aws_sns_topic.notifications.arn
    }]
  })
}

# ─────────────────────────────────────────
# SNS Topic
# ─────────────────────────────────────────
resource "aws_sns_topic" "notifications" {
  name = "${var.project_name}-notifications"
}

# ─────────────────────────────────────────
# SQS Queue
# ─────────────────────────────────────────
resource "aws_sqs_queue" "notifications" {
  name                      = "${var.project_name}-notifications-queue"
  visibility_timeout_seconds = 60
  message_retention_seconds  = 86400  # 1 día
  receive_wait_time_seconds  = 10     # long polling

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.notifications_dlq.arn
    maxReceiveCount     = 3
  })
}

# Dead Letter Queue para mensajes fallidos
resource "aws_sqs_queue" "notifications_dlq" {
  name = "${var.project_name}-notifications-dlq"
}

# Política que permite a SNS enviar mensajes a SQS
resource "aws_sqs_queue_policy" "notifications" {
  queue_url = aws_sqs_queue.notifications.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "sns.amazonaws.com" }
      Action    = "sqs:SendMessage"
      Resource  = aws_sqs_queue.notifications.arn
      Condition = {
        ArnEquals = {
          "aws:SourceArn" = aws_sns_topic.notifications.arn
        }
      }
    }]
  })
}

# ─────────────────────────────────────────
# Suscripción SNS → SQS
# ─────────────────────────────────────────
resource "aws_sns_topic_subscription" "sqs" {
  topic_arn = aws_sns_topic.notifications.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.notifications.arn
}

# ─────────────────────────────────────────
# IAM Role para Lambda de Notificaciones
# ─────────────────────────────────────────
resource "aws_iam_role" "notification_lambda_role" {
  name = "${var.project_name}-notification-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "notification_lambda_basic" {
  role       = aws_iam_role.notification_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "notification_lambda_sqs" {
  name = "${var.project_name}-notification-sqs-policy"
  role = aws_iam_role.notification_lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ]
        Resource = aws_sqs_queue.notifications.arn
      },
      {
        Effect   = "Allow"
        Action   = ["ses:SendEmail", "ses:SendRawEmail"]
        Resource = "*"
      }
    ]
  })
}

# ─────────────────────────────────────────
# CloudWatch Log Group para notification Lambda
# ─────────────────────────────────────────
resource "aws_cloudwatch_log_group" "notification_lambda_logs" {
  name              = "/aws/lambda/${var.project_name}-notification-lambda"
  retention_in_days = 7
}

# ─────────────────────────────────────────
# Lambda de Notificaciones
# ─────────────────────────────────────────
resource "aws_lambda_function" "notification" {
  function_name = "${var.project_name}-notification-lambda"
  role          = aws_iam_role.notification_lambda_role.arn
  handler       = "bootstrap"
  runtime       = "provided.al2"
  filename      = var.notification_lambda_zip_path
  timeout       = 60
  memory_size   = 128

  source_code_hash = filebase64sha256(var.notification_lambda_zip_path)

  environment {
    variables = {
      SES_SENDER_EMAIL = var.ses_sender_email
      AWS_SES_REGION   = var.aws_region
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.notification_lambda_basic,
    aws_cloudwatch_log_group.notification_lambda_logs,
  ]
}

# ─────────────────────────────────────────
# Event Source Mapping: SQS → Lambda
# ─────────────────────────────────────────
resource "aws_lambda_event_source_mapping" "sqs_to_lambda" {
  event_source_arn = aws_sqs_queue.notifications.arn
  function_name    = aws_lambda_function.notification.arn
  batch_size       = 1
  enabled          = true
}

# ─────────────────────────────────────────
# Lambda principal existente (ya definida en main.tf anterior)
# Solo agregamos SNS_TOPIC_ARN como variable de entorno
# ─────────────────────────────────────────
resource "aws_lambda_function_event_invoke_config" "api_async" {
  function_name = aws_lambda_function.api.function_name
}
