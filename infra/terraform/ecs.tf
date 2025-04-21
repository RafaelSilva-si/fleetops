resource "aws_ecs_cluster" "express_cluster" {
  name = "express-cluster"
}

resource "aws_ecs_task_definition" "app" {
  family                   = "express-task"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  network_mode             = "awsvpc"
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn

  container_definitions = jsonencode([
    {
      name  = "express-backend"
      image = "${aws_ecr_repository.backend.repository_url}:latest"
      portMappings = [{
        containerPort = 3000
        protocol      = "tcp"
      }]
      environment = [
        {
          name  = "SQS_QUEUE_URL"
          value = "https://sqs.us-east-1.amazonaws.com/422574702497/event-queue"
        }
      ]
    }
  ])
}

resource "aws_ecs_service" "app" {
  name            = "express-service"
  cluster         = aws_ecs_cluster.express_cluster.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = module.vpc.public_subnets
    security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.app_tg.arn
    container_name   = "express-backend"
    container_port   = 3000
  }

  depends_on = [aws_lb_listener.app_listener]
}
