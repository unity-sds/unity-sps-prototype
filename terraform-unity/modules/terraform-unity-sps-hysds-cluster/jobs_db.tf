resource "aws_sns_topic" "jobs_data" {
  name                        = "${var.project}-${var.venue}-${var.service_area}-SNS-JobsDataTopic-${local.counter}.fifo"
  fifo_topic                  = true
  content_based_deduplication = true
  tags = merge(local.common_tags, {
    # Add or overwrite specific tags for this resource
    Name      = "${var.project}-${var.venue}-${var.service_area}-SNS-JobsDataTopic-${local.counter}"
    Component = "SNS"
    Stack     = "SNS"
  })
}

resource "aws_sns_topic_policy" "jobs_data" {
  arn = aws_sns_topic.jobs_data.arn
  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "__default_policy_ID"
    Statement = [
      {
        Sid    = "DefaultStatementID"
        Effect = "Allow"
        "Principal" : {
          "AWS" : "*"
        },
        Action = [
          "SNS:GetTopicAttributes",
          "SNS:SetTopicAttributes",
          "SNS:AddPermission",
          "SNS:RemovePermission",
          "SNS:DeleteTopic",
          "SNS:Subscribe",
          "SNS:ListSubscriptionsByTopic",
          "SNS:Publish"
        ]
        Resource = aws_sns_topic.jobs_data.arn,
        "Condition" : {
          "StringEquals" : {
            "AWS:SourceOwner" : data.aws_caller_identity.current.account_id
          }
        }
      }
    ]
  })
}

resource "null_resource" "build_lambda_package" {
  triggers = {
    # source_code_hash = local.source_code_hash
    always_run = "${timestamp()}"
  }

  provisioner "local-exec" {
    interpreter = ["bash", "-c"]
    command = <<EOF
      cd ${path.module}/../../../lambdas/jobs_data_ingest
      python3.9 -m venv venv
      source venv/bin/activate
      pip install -e .
      mkdir -p lambda_package
      cp -R venv/lib/python3.9/site-packages/* ./lambda_package
      cp -R ./*.py ./lambda_package
      cd lambda_package
      zip -r ../../lambda_package.zip .
      deactivate
      cd ../..
      rm -rf ${path.module}/../../../lambdas/jobs_data_ingest/venv
      rm -rf ${path.module}/../../../lambdas/jobs_data_ingest/lambda_package
    EOF
  }
}

resource "aws_iam_role" "lambda_role" {
  name = "${var.project}-${var.venue}-${var.service_area}-IAM-JobsDataIngestLambdaRole-${local.counter}"

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

  permissions_boundary = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/mcp-tenantOperator-AMI-APIG"

  tags = merge(local.common_tags, {
    Name      = "${var.project}-${var.venue}-${var.service_area}-IAM-JobsDataIngestLambdaRole-${local.counter}"
    Component = "lambda"
    Stack     = "lambda"
  })
}

resource "aws_iam_policy" "sqs_access_policy" {
  name        = "${var.project}-${var.venue}-${var.service_area}-IAM-LambdaSQSAccessPolicy-${local.counter}"
  description = "Policy to allow Lambda to read messages from the SQS queue"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ]
        Effect   = "Allow"
        Resource = aws_sqs_queue.jobs_data_ingest_queue.arn
      }
    ]
  })

  tags = merge(local.common_tags, {
    Name      = "${var.project}-${var.venue}-${var.service_area}-IAM-LambdaSQSAccessPolicy-${local.counter}"
    Component = "IAM"
    Stack     = "IAM"
  })
}

resource "aws_iam_policy_attachment" "sqs_access_policy_attachment" {
  name       = "${var.project}-${var.venue}-${var.service_area}-IAM-LambdaSQSAccessPolicyAttachment-${local.counter}"
  roles      = [aws_iam_role.lambda_role.name]
  policy_arn = aws_iam_policy.sqs_access_policy.arn
}

resource "aws_iam_policy" "cloudwatch_logs_access_policy" {
  name        = "${var.project}-${var.venue}-${var.service_area}-IAM-LambdaCloudWatchLogsAccessPolicy-${local.counter}"
  description = "Policy to allow Lambda to write to CloudWatch Logs"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Effect   = "Allow"
        Resource = "arn:aws:logs:*:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/*"
      }
    ]
  })

  tags = merge(local.common_tags, {
    Name      = "${var.project}-${var.venue}-${var.service_area}-IAM-LambdaCloudWatchLogsAccessPolicy-${local.counter}"
    Component = "IAM"
    Stack     = "IAM"
  })
}

resource "aws_iam_policy_attachment" "cloudwatch_logs_access_policy_attachment" {
  name       = "${var.project}-${var.venue}-${var.service_area}-IAM-CloudWatchLogsAccessPolicyAttachment-${local.counter}"
  roles      = [aws_iam_role.lambda_role.name]
  policy_arn = aws_iam_policy.cloudwatch_logs_access_policy.arn
}


resource "aws_lambda_function" "jobs_data_ingest" {
  function_name = "${var.project}-${var.venue}-${var.service_area}-lambda-JobsDataIngest-${local.counter}"
  role          = aws_iam_role.lambda_role.arn
  handler       = "jobs_data_ingest.lambda_handler"
  runtime       = "python3.9"
  memory_size   = 128
  timeout       = 10

  # Use the created ZIP file as the source of your Lambda function
  filename = "${path.module}/../../../lambda_package.zip"
  #   source_code_hash = filebase64sha256(pathexpand("${path.module}/../../lambdas/jobs_data_ingest/lambda_package.zip"))

  environment {
    variables = {
      REGION = var.region
      # OPENSEARCH_DOMAIN_ENDPOINT = aws_elasticsearch_domain.jobs_database.endpoint
      ELASTICSEARCH_ENDPOINT = "http://${data.kubernetes_service.jobs-es.status[0].load_balancer[0].ingress[0].hostname}:${var.service_port_map.jobs_es}"
    }
  }

  tags = merge(local.common_tags, {
    # Add or overwrite specific tags for this resource
    Name      = "${var.project}-${var.venue}-${var.service_area}-lambda-JobsDataIngest-${local.counter}"
    Component = "lambda"
    Stack     = "lambda"
  })

  depends_on = [
    null_resource.build_lambda_package
  ]
}

resource "aws_sqs_queue" "jobs_data_ingest_queue" {
  name                        = "${var.project}-${var.venue}-${var.service_area}-SQS-JobsDataIngestQueue-${local.counter}.fifo"
  fifo_queue                  = true
  content_based_deduplication = true
  message_retention_seconds   = 1209600
  visibility_timeout_seconds  = 30

  tags = merge(local.common_tags, {
    # Add or overwrite specific tags for this resource
    Name      = "${var.project}-${var.venue}-${var.service_area}-SQS-JobsDataIngestQueue-${local.counter}"
    Component = "SQS"
    Stack     = "SQS"
  })
}


resource "aws_sns_topic_subscription" "sqs_subscription" {
  topic_arn = aws_sns_topic.jobs_data.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.jobs_data_ingest_queue.arn
}

resource "aws_sqs_queue_policy" "jobs_data_queue" {
  queue_url = aws_sqs_queue.jobs_data_ingest_queue.id

  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "__default_policy_ID"
    Statement = [
      {
        Sid    = "__owner_statement"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "SQS:*"
        Resource = aws_sqs_queue.jobs_data_ingest_queue.arn
      },
      {
        Sid    = "__sender_statement"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "SQS:SendMessage"
        Resource = aws_sqs_queue.jobs_data_ingest_queue.arn
      },
      {
        Sid    = "__receiver_statement"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action = [
          "SQS:ChangeMessageVisibility",
          "SQS:DeleteMessage",
          "SQS:ReceiveMessage"
        ]
        Resource = aws_sqs_queue.jobs_data_ingest_queue.arn
      },
      {
        Sid    = "topic-subscription-${aws_sns_topic_subscription.sqs_subscription.arn}"
        Effect = "Allow"
        Principal = {
          AWS = "*"
        }
        Action   = "SQS:SendMessage"
        Resource = aws_sqs_queue.jobs_data_ingest_queue.arn
        Condition = {
          ArnLike = {
            "aws:SourceArn" = aws_sns_topic.jobs_data.arn
          }
        }
      }
    ]
  })
}

resource "aws_lambda_event_source_mapping" "sqs_event_source_mapping_jobs_data_ingest" {
  event_source_arn = aws_sqs_queue.jobs_data_ingest_queue.arn
  function_name    = aws_lambda_function.jobs_data_ingest.function_name
}

resource "aws_ssm_parameter" "jobs-db-url-param" {
  name        = "/unity/sps/${var.deployment_name}/jobsDb/url"
  description = "Full URL of the jobs db load balancer, including port for accesing jobs db"
  type        = "String"
  value       = "http://${data.kubernetes_service.jobs-es.status[0].load_balancer[0].ingress[0].hostname}:${var.service_port_map.jobs_es}"
}

# resource "aws_elasticsearch_domain" "jobs_database" {
#   domain_name           = "${var.project}-${var.venue}-${var.service_area}-es-jobs-${local.counter}"
#   elasticsearch_version = "7.10"

#   cluster_config {
#     instance_type = "t3.small.elasticsearch"
#   }

#   ebs_options {
#     ebs_enabled = true
#     volume_size = 20
#   }

#   tags = merge(local.common_tags, {
#     # Add or overwrite specific tags for this resource
#     Name      = "${var.project}-${var.venue}-${var.service_area}-OpenSearch-JobsDatabase-${local.counter}"
#     Component = "OpenSearch"
#     Stack     = "OpenSearch"
#   })
# }

# output "opensearch_jobs_database_endpoint" {
#   value = aws_elasticsearch_domain.jobs_database.endpoint
# }

# resource "aws_elasticsearch_domain_policy" "jobs_database" {
#   domain_name = aws_elasticsearch_domain.jobs_database.domain_name
#   access_policies = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action   = "opensearch:*"
#         Effect   = "Allow"
#         Resource = "${aws_elasticsearch_domain.jobs_database.arn}/*"
#         Principal = {
#           AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
#         }
#       },
#       {
#         Action = [
#           "es:ESHttpGet",
#           "es:ESHttpPut",
#           "es:ESHttpPost"
#         ],
#         Effect   = "Allow"
#         Resource = "${aws_elasticsearch_domain.jobs_database.arn}/*"
#         Principal = {
#           AWS = aws_iam_role.lambda_role.arn
#         }
#       }
#     ]
#   })
# }


# data "local_file" "jobs_index_template" {
#   filename = "${path.module}/../../jobs-database/es_templates/jobs_index_template.json"
# }

# resource "null_resource" "upload_index_template" {
#   #   triggers = {
#   #     opensearch_endpoint = aws_elasticsearch_domain.jobs_database.endpoint
#   #   }
#   triggers = {
#     # source_code_hash = local.source_code_hash
#     always_run = "${timestamp()}"
#   }

#   # provisioner "local-exec" {
#   #   command = "curl -X PUT '${aws_elasticsearch_domain.jobs_database.endpoint}/_template/jobs_template' -H 'Content-Type: application/json' -d '${data.local_file.jobs_index_template.content}'"
#   # }
#   provisioner "local-exec" {
#     command = "curl -X PUT 'http://${data.kubernetes_service.jobs-es.status[0].load_balancer[0].ingress[0].hostname}:${var.service_port_map.jobs_es}/_index_template/jobs' -H 'Content-Type: application/json' -d '${data.local_file.jobs_index_template.content}'"
#   }
# }

# resource "aws_iam_policy" "opensearch_access_policy" {
#   name        = "${var.project}-${var.venue}-${var.service_area}-IAM-LambdaOpenSearchAccessPolicy-${local.counter}"
#   description = "Policy to allow Lambda to insert data into the OpenSearch domain"

#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = [
#           "es:ESHttpGet",
#           "es:ESHttpPut",
#           "es:ESHttpPost"
#         ],
#         Effect   = "Allow"
#         Resource = "${aws_elasticsearch_domain.jobs_database.arn}/*"
#       }
#     ]
#   })

#   tags = merge(local.common_tags, {
#     Name      = "${var.project}-${var.venue}-${var.service_area}-IAM-LambdaOpenSearchAccessPolicy-${local.counter}"
#     Component = "IAM"
#     Stack     = "IAM"
#   })
# }

# resource "aws_iam_policy_attachment" "opensearch_access_policy_attachment" {
#   name       = "${var.project}-${var.venue}-${var.service_area}-IAM-OpenSearchAccessPolicyAttachment-${local.counter}"
#   roles      = [aws_iam_role.lambda_role.name]
#   policy_arn = aws_iam_policy.opensearch_access_policy.arn
# }
