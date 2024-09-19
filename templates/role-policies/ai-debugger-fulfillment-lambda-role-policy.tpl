{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "secretsmanager:DescribeSecret",
                "secretsmanager:GetSecretValue"
            ],
            "Resource": ${jsonencode(resource_ai_debugger_secrets)},
            "Effect": "Allow",
            "Sid": "SecretsManagerGet"
        },
        {
            "Action": [
              "kms:Decrypt"
            ],
            "Resource": "${ai_debugger_kms_arn}",
            "Effect": "Allow",
            "Sid": "KMSDecrypt"
        },
        {
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": "arn:${data_aws_partition}:logs:${data_aws_region}:${data_aws_account_id}:log-group:${local_log_group_name}/*",
            "Effect": "Allow",
            "Sid": "CloudWatchLogOps"
        },
        {
            "Action": [
                "xray:PutTraceSegments",
                "xray:PutTelemetryRecords"
            ],
            "Resource": "*",
            "Effect": "Allow",
            "Sid": "XRayTracing"
        }
    ]
}