provider "aws" {
  region = "us-east-1"
}

# Define o caminho para o diretório do código da Lambda
variable "lambda_source_path" {
  default = "./lambdas" # Caminho para o diretório do código da Lambda
}

# Usando o recurso archive_file para empacotar a Lambda
resource "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = var.lambda_source_path
  output_path = "${path.module}/lambda.zip"
}

# Upload do código da Lambda para o S3
resource "aws_s3_bucket_object" "lambda_zip" {
  bucket = "my-lambda-code-bucket" 
  key    = "lambda.zip"
  source = archive_file.lambda_zip.output_path
}

# Função Lambda
resource "aws_lambda_function" "event_consumer_lambda" {
  function_name = "event-consumer"
  role          = aws_iam_role.lambda_execution_role.arn
  handler       = "index.handler"
  runtime       = "nodejs18.x"
  timeout       = 10

  # Referenciando o código da Lambda do S3
  s3_bucket = aws_s3_bucket_object.lambda_zip.bucket
  s3_key    = aws_s3_bucket_object.lambda_zip.key
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
