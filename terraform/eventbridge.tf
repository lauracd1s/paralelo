# ─────────────────────────────────────────
# IAM Role para EventBridge Scheduler
# ─────────────────────────────────────────
resource "aws_iam_role" "scheduler_role" {
  name = "${var.project_name}-scheduler-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "scheduler.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "scheduler_sns" {
  name = "${var.project_name}-scheduler-sns-policy"
  role = aws_iam_role.scheduler_role.id

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
# EventBridge Scheduler — cada 5 minutos
# ─────────────────────────────────────────
resource "aws_scheduler_schedule" "every_5_minutes" {
  name        = "${var.project_name}-schedule-5min"
  description = "Publica un mensaje en SNS cada 5 minutos automáticamente"

  # Expresión rate: ejecutar cada 5 minutos
  schedule_expression          = "rate(5 minutes)"
  schedule_expression_timezone = "America/Santo_Domingo"

  # No tiene fecha de inicio ni fin — corre indefinidamente
  state = "ENABLED"

  flexible_time_window {
    mode = "OFF" # ejecución exacta, sin ventana flexible
  }

  target {
    arn      = aws_sns_topic.notifications.arn
    role_arn = aws_iam_role.scheduler_role.arn

    # Mensaje que se publica en SNS cada 5 minutos
    input = jsonencode({
      email   = "lauras@utesa.edu"
      subject = "Reporte Automático — EventBridge Scheduler"
      message = "Este mensaje fue generado automáticamente por EventBridge Scheduler cada 5 minutos. Sistema Paralelo API — UTESA funcionando correctamente."
    })
  }
}

# ─────────────────────────────────────────
# CloudWatch Log Group para el scheduler
# ─────────────────────────────────────────
resource "aws_cloudwatch_log_group" "scheduler_logs" {
  name              = "/aws/scheduler/${var.project_name}-schedule-5min"
  retention_in_days = 7
}
