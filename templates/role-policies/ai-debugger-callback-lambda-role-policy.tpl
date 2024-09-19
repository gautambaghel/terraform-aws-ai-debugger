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
        }
    ]
}