# Define o caminho para o diretório do código da Lambda
variable "lambda_source_path" {
  default = "../../lambda" # Caminho para o diretório do código da Lambda
}

# Usando o recurso archive_file para empacotar o código da Lambda
resource "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = var.lambda_source_path
  output_path = "${path.module}/lambda.zip"
}

# Função Lambda diretamente com o código compactado
resource "aws_lambda_function" "event_consumer_lambda" {
  function_name = "event-consumer"
  role          = aws_iam_role.lambda_execution_role.arn
  handler       = "index.handler"
  runtime       = "nodejs18.x"
  timeout       = 10

  # Referenciando o arquivo ZIP diretamente
  filename = archive_file.lambda_zip.output_path
}

# Definindo a IAM Role para Lambda
resource "aws_iam_role" "lambda_execution_role" {
  name = "lambda-sqs-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_dynamodb_table" "events_table" {
  name         = "EventsTable"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "vehicleId"
  range_key    = "timestamp"

  attribute {
    name = "vehicleId"
    type = "S"
  }

  attribute {
    name = "timestamp"
    type = "S"
  }
}

resource "aws_iam_role_policy" "lambda_policy" {
  name = "lambda-inline-policy"
  role = aws_iam_role.lambda_execution_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ]
        Resource = "*" # você pode especificar a ARN da fila aqui se quiser restringir
      },
      {
        Effect = "Allow"
        Action = [
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:GetItem"
        ]
        Resource = aws_dynamodb_table.events_table.arn
      }
    ]
  })
}

# Configurando o Trigger da Lambda para a SQS
resource "aws_lambda_event_source_mapping" "lambda_sqs_trigger" {
  event_source_arn = aws_sqs_queue.event_queue.arn
  function_name    = aws_lambda_function.event_consumer_lambda.function_name
  batch_size       = 1
  enabled          = true
}

# Fila SQS
resource "aws_sqs_queue" "event_queue" {
  name = "event-queue"
}

output "lambda_function_name" {
  value = aws_lambda_function.event_consumer_lambda.function_name
}

output "sqs_queue_url" {
  value = aws_sqs_queue.event_queue.url
}
