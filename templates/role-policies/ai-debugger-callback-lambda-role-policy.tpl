{
    "Version": "2012-10-17",
    "Statement": [
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
                "secretsmanager:DescribeSecret",
                "secretsmanager:GetSecretValue"
            ],
            "Resource": ${jsonencode(resource_ai_debugger_secrets)},
            "Effect": "Allow",
            "Sid": "SecretsManagerGet"
        }
    ]
}