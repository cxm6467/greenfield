terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# ============================================
# SSM Parameter Store - Bedrock API Key
# ============================================

resource "aws_ssm_parameter" "bedrock_api_key" {
  name      = "/${var.app_name}/${var.environment}/bedrock_api_key"
  type      = "SecureString"
  value     = var.bedrock_api_key
  overwrite = true

  tags = {
    Name        = "${var.app_name}-bedrock-key"
    Environment = var.environment
  }
}

# ============================================
# IAM Role for Lambda
# ============================================

resource "aws_iam_role" "lambda_role" {
  name = "${var.app_name}-lambda-role-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "${var.app_name}-lambda-role"
    Environment = var.environment
  }
}

# Basic Lambda execution policy (logs)
resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Custom policy for Bedrock + SSM access
resource "aws_iam_role_policy" "lambda_bedrock_ssm" {
  name = "${var.app_name}-lambda-bedrock-ssm-policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "BedrockInvoke"
        Effect = "Allow"
        Action = [
          "bedrock:InvokeModel"
        ]
        Resource = "*"
      },
      {
        Sid    = "SSMGetParameter"
        Effect = "Allow"
        Action = [
          "ssm:GetParameter"
        ]
        Resource = aws_ssm_parameter.bedrock_api_key.arn
      }
    ]
  })
}

# ============================================
# Lambda Function
# ============================================

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambda"
  output_path = "${path.module}/lambda.zip"
}

resource "aws_lambda_function" "proxy" {
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  function_name    = "${var.app_name}-proxy-${var.environment}"
  role             = aws_iam_role.lambda_role.arn
  handler          = "index.handler"
  runtime          = "nodejs18.x"
  timeout          = 30
  memory_size      = 256

  environment {
    variables = {
      SSM_PARAM_NAME = aws_ssm_parameter.bedrock_api_key.name
      BEDROCK_MODEL  = var.bedrock_model
    }
  }

  tags = {
    Name        = "${var.app_name}-proxy"
    Environment = var.environment
  }
}

# ============================================
# API Gateway HTTP API
# ============================================

resource "aws_apigatewayv2_api" "proxy" {
  name          = "${var.app_name}-api-${var.environment}"
  protocol_type = "HTTP"

  cors_configuration {
    allow_origins     = ["*"]
    allow_methods     = ["GET", "POST", "OPTIONS"]
    allow_headers     = ["*"]
    expose_headers    = ["*"]
    max_age           = 300
    credentials_allowed = false
  }

  tags = {
    Name        = "${var.app_name}-api"
    Environment = var.environment
  }
}

# Integration between API Gateway and Lambda
resource "aws_apigatewayv2_integration" "lambda" {
  api_id           = aws_apigatewayv2_api.proxy.id
  integration_type = "AWS_PROXY"
  integration_method = "POST"
  payload_format_version = "2.0"
  target_uri = aws_lambda_function.proxy.invoke_arn
}

# Routes
resource "aws_apigatewayv2_route" "health" {
  api_id    = aws_apigatewayv2_api.proxy.id
  route_key = "GET /api/claude/health"
  target    = "integrations/${aws_apigatewayv2_integration.lambda.id}"
}

resource "aws_apigatewayv2_route" "messages" {
  api_id    = aws_apigatewayv2_api.proxy.id
  route_key = "POST /api/claude/messages"
  target    = "integrations/${aws_apigatewayv2_integration.lambda.id}"
}

# Catch-all for OPTIONS (preflight)
resource "aws_apigatewayv2_route" "options" {
  api_id    = aws_apigatewayv2_api.proxy.id
  route_key = "$default"
  target    = "integrations/${aws_apigatewayv2_integration.lambda.id}"
}

# Stage
resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.proxy.id
  name        = "$default"
  auto_deploy = true

  default_route_settings {
    logging_level = "ERROR"
  }
}

# Lambda permission for API Gateway
resource "aws_lambda_permission" "api_gateway" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.proxy.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.proxy.execution_arn}/*/*"
}

# ============================================
# S3 Bucket for Static Web Assets
# ============================================

resource "aws_s3_bucket" "web" {
  bucket = "${var.app_name}-web-${var.environment}-${data.aws_caller_identity.current.account_id}"

  tags = {
    Name        = "${var.app_name}-web"
    Environment = var.environment
  }
}

# Block public access
resource "aws_s3_bucket_public_access_block" "web" {
  bucket = aws_s3_bucket.web.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# CloudFront Origin Access Control (OAC)
resource "aws_cloudfront_origin_access_control" "s3_oac" {
  name                              = "${var.app_name}-s3-oac"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# S3 bucket policy - allow CloudFront access only
resource "aws_s3_bucket_policy" "web" {
  bucket = aws_s3_bucket.web.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudFrontAccess"
        Effect = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action   = "s3:GetObject"
        Resource = "${aws_s3_bucket.web.arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.web.arn
          }
        }
      }
    ]
  })
}

# ============================================
# CloudFront Distribution
# ============================================

resource "aws_cloudfront_distribution" "web" {
  enabled = true
  is_ipv6_enabled = true
  default_root_object = "index.html"

  # Origin 1: API Gateway
  origin {
    domain_name = replace(aws_apigatewayv2_api.proxy.api_endpoint, "/^https?://([^/]*).*/", "$1")
    origin_id   = "api_gateway"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  # Origin 2: S3
  origin {
    domain_name            = aws_s3_bucket.web.bucket_regional_domain_name
    origin_id              = "s3"
    origin_access_control_id = aws_cloudfront_origin_access_control.s3_oac.id
  }

  # Default behavior: S3 (static content)
  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "s3"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
    compress               = true
  }

  # Cached behavior: API routes (proxy)
  ordered_cache_behavior {
    path_pattern     = "/api/claude/*"
    allowed_methods  = ["GET", "HEAD", "POST", "PUT", "DELETE", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "api_gateway"

    forwarded_values {
      query_string = true
      headers {
        header_names = ["*"]
      }

      cookies {
        forward = "all"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 0
    max_ttl                = 0
    compress               = true
  }

  # SPA catch-all: /index.html
  ordered_cache_behavior {
    path_pattern     = "*.html"
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "s3"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 0
    max_ttl                = 0
    compress               = true
  }

  # Cache policy for static assets (JS, CSS, images)
  ordered_cache_behavior {
    path_pattern     = "*.@(js|css|jpg|jpeg|gif|png|svg|webp|ico)"
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "s3"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 31536000
    max_ttl                = 31536000
    compress               = true
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = var.domain_name == "" ? true : false
    acm_certificate_arn            = var.domain_name != "" ? aws_acm_certificate.domain[0].arn : null
    ssl_support_method             = var.domain_name != "" ? "sni-only" : null
    minimum_protocol_version       = var.domain_name != "" ? "TLSv1.2_2021" : null
  }

  aliases = var.domain_name != "" ? [var.domain_name] : []

  tags = {
    Name        = "${var.app_name}-cdn"
    Environment = var.environment
  }

  depends_on = [aws_s3_bucket_policy.web]
}

# ============================================
# ACM Certificate (for custom domain)
# ============================================

resource "aws_acm_certificate" "domain" {
  count             = var.domain_name != "" ? 1 : 0
  domain_name       = var.domain_name
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name        = "${var.app_name}-cert"
    Environment = var.environment
  }
}

# DNS validation record
resource "aws_route53_record" "cert_validation" {
  count   = var.domain_name != "" ? 1 : 0
  zone_id = var.route53_zone_id
  name    = aws_acm_certificate.domain[0].domain_validation_options[0].resource_record_name
  type    = aws_acm_certificate.domain[0].domain_validation_options[0].resource_record_type
  records = [aws_acm_certificate.domain[0].domain_validation_options[0].resource_record_value]
  ttl     = 60
}

# Wait for certificate validation
resource "aws_acm_certificate_validation" "domain" {
  count           = var.domain_name != "" ? 1 : 0
  certificate_arn = aws_acm_certificate.domain[0].arn

  timeouts {
    create = "5m"
  }

  depends_on = [aws_route53_record.cert_validation]
}

# ============================================
# Route 53 DNS Record (for custom domain)
# ============================================

resource "aws_route53_record" "app" {
  count   = var.domain_name != "" ? 1 : 0
  zone_id = var.route53_zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.web.domain_name
    zone_id                = aws_cloudfront_distribution.web.hosted_zone_id
    evaluate_target_health = false
  }
}

# ============================================
# Data Source: Current AWS Account ID
# ============================================

data "aws_caller_identity" "current" {}
