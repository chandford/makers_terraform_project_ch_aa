resource "aws_ecr_repository" "ch_aa_ecr_repo" {
  name                 = "ch_aa_ecr_repo"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_elastic_beanstalk_application" "ch_aa_beanstalk_app" {
  name        = "ch-aa-task-listing-app"
  description = "Task listing app"
}

resource "aws_elastic_beanstalk_environment" "ch_aa_beanstalk_app_environment" {
  name        = "ch-aa-task-listing-app-environment"
  application = aws_elastic_beanstalk_application.ch_aa_beanstalk_app.name

  solution_stack_name = "64bit Amazon Linux 2023 v4.0.1 running Docker" # "Platform" on console

  # "setting" = option settings to configure the new environment, which override specific defauly values
  # Below configure the EC2 instances for your environment
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile" # Enables AWS IAM users and AWS services to access temporary security credentials
    value     = aws_iam_instance_profile.ch_aa_beanstalk_app_ec2_instance_profile.name
  }
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "EC2KeyName" # You can use a key pair to securely log into your EC2 instance.
    value     = "CHTerraform"
  }
}

resource "aws_iam_instance_profile" "ch_aa_beanstalk_app_ec2_instance_profile" {
  name = "ch-aa-ec2-task-listing-app-ec2-instance-profile" # name must be unique
  role = aws_iam_role.ch_aa_beanstalk_app_ec2_role.name
}

resource "aws_iam_role" "ch_aa_beanstalk_app_ec2_role" {
  name = "ch-aa-task-listing-app-ec2-instance-role"
  # Allows the EC2 instances in our Elastic Beanstalk environment to assume take on this role
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Effect = "Allow"
        Sid    = ""
      }
    ]
  })
}
  tags = {
    Environment = "test"
  }
>>>>>>> 3efafd4 (Add GitHub Actions CI/CD and test change to Terraform)
