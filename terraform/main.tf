# IAM role for App Runner instance
resource "aws_iam_role" "apprunner_instance" {
  name = "${var.service_name}-instance-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "tasks.apprunner.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "apprunner_ecr" {
  role       = aws_iam_role.apprunner_instance.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSAppRunnerServicePolicyForECRAccess"
}

# IAM role for App Runner access (ECR pull)
resource "aws_iam_role" "apprunner_access" {
  name = "${var.service_name}-access-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "build.apprunner.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "apprunner_access_ecr" {
  role       = aws_iam_role.apprunner_access.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSAppRunnerServicePolicyForECRAccess"
}

resource "aws_apprunner_service" "nodejs_argo" {
  service_name = var.service_name

  source_configuration {
    authentication_configuration {
      access_role_arn = aws_iam_role.apprunner_access.arn
    }

    image_repository {
      image_identifier      = var.image_identifier
      image_repository_type = "ECR"

      image_configuration {
        port = tostring(var.port)

        runtime_environment_variables = {
          PORT         = tostring(var.port)
          UUID         = var.uuid
          ARGO_DOMAIN  = var.argo_domain
          ARGO_AUTH    = var.argo_auth
          CFIP         = var.cfip
          CFPORT       = var.cfport
          NAME         = var.name_prefix
          SUB_PATH     = var.sub_path
          FILE_PATH    = "/tmp/.npm"
          NEZHA_SERVER = var.nezha_server
          NEZHA_KEY    = var.nezha_key
          CHAT_ID      = var.chat_id
          BOT_TOKEN    = var.bot_token
          SHOW_LOG     = var.show_log
        }
      }
    }

    auto_deployments_enabled = false
  }

  instance_configuration {
    cpu               = var.cpu
    memory            = var.memory
    instance_role_arn = aws_iam_role.apprunner_instance.arn
  }

  health_check_configuration {
    protocol            = "HTTP"
    path                = "/"
    interval            = 20
    timeout             = 5
    healthy_threshold   = 1
    unhealthy_threshold = 5
  }

  tags = {
    Name    = var.service_name
    Managed = "env0"
  }
}
