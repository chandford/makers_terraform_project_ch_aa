resource "aws_ecr_repository" "ch_aa_ecr_repo" {
  name                 = "ch_aa_ecr_repo"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Environment = "test"
  }
}

resource "aws_s3_bucket" "ch_aa_docker_storage_bucket" {
  bucket = "ch-aa-docker-storage-bucket"
}

resource "aws_elastic_beanstalk_application" "ch_aa_beanstalk_app" {
  name        = "ch-aa-task-listing-app"
  description = "Task listing app"
}

resource "aws_elastic_beanstalk_environment" "ch_aa_beanstalk_app_environment" {
  name        = "ch-aa-task-listing-app-environment"
  application = aws_elastic_beanstalk_application.ch_aa_beanstalk_app.name

  solution_stack_name = "64bit Amazon Linux 2023 v4.0.1 running Docker" # "Platform" on console

  # Configure the EC2 instances for your environment
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

resource "aws_iam_role_policy_attachment" "ch_aa_ec2_ecr_readonly" {
  role       = aws_iam_role.ch_aa_beanstalk_app_ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy_attachment" "ch_aa_ec2_webtier_policy" {
  role       = aws_iam_role.ch_aa_beanstalk_app_ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkWebTier"
}

resource "aws_iam_role_policy_attachment" "ch_aa_ec2_multicontainer_policy" {
  role       = aws_iam_role.ch_aa_beanstalk_app_ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkMulticontainerDocker"
}

resource "aws_iam_role_policy_attachment" "ch_aa_ec2_workertier_policy" {
  role       = aws_iam_role.ch_aa_beanstalk_app_ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkWorkerTier"
}

resource "aws_db_instance" "ch_aa_rds_app" {
  allocated_storage   = 10
  engine              = "postgres"
  engine_version      = "17.4"
  instance_class      = "db.t3.micro"
  identifier          = "ch-aa-task-listing-app-prod" # name is unique for all DB instances owned by your AWS account in current region
  db_name             = "CHAATaskListingAppPSQLDB"
  username            = "CHAAroot"
  password            = "CHAApassword"
  skip_final_snapshot = true
  publicly_accessible = true
}