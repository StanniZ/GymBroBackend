data "aws_caller_identity" "current" {}

resource "aws_iam_role" "server" {
  name = "gymbro-server-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "ec2.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "gymbro-server-role"
  }
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.server.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy" "ecr_pull" {
  name = "PullGymBroImages"
  role = aws_iam_role.server.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "ecr:GetAuthorizationToken"
        ]

        Resource = "*"
      },
      {
        Effect = "Allow"

        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:BatchGetImage",
          "ecr:GetDownloadUrlForLayer"
        ]

        Resource = "arn:aws:ecr:eu-central-1:${data.aws_caller_identity.current.account_id}:repository/gymbro-backend"
      }
    ]
  })
}

resource "aws_iam_instance_profile" "server" {
  name = "gymbro-server-profile"
  role = aws_iam_role.server.name
}
