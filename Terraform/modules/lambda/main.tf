provider "aws" {
    region          = var.aws_region
    access_key      = var.aws_access_key
    secret_key      = var.aws_secret_key
    version         = "~> 2.69"
}

variable "aws_access_key" {
    type            = string
    default         = ""
}

variable "aws_secret_key" {
    type            = string
    default         = ""
}

variable "cidr_block" {
    type            = string
    description     = "VPC cidr block."
    default         = "192.168.0.0/24"
}

provider "archive" {
    version = "~> 1.3"
}

data "archive_file" "zip" {
    type            = "zip"
    source_file     = "greet_lambda.py"
    output_path     = "greet_lambda.zip"
}

###############################
#Create VPC for  infrastructure
###############################

resource "aws_vpc" "main" {
    cidr_block      = var.cidr_block

    tags = {
        "Name"      = "VPC for Udacity project"
    }
}

# Connect to the internet via IGW

resource "aws_internet_gateway" "main" {
    vpc_id          = aws_vpc.main.id

    tags = {
        "Name"      = "IGW for internet facing"
    }
}

# Create a public subnet

resource "aws_subnet" "public" {
    count           = 1
    vpc_id          = aws_vpc.main.id
    cidr_block      = cidrsubnet(var.cidr_block, 1, count.index)
    availability_zone = "us-east-1a"
    map_public_ip_on_launch = true

    tags = {
        "Name"      = "Public Subnet"
    }
}


########################
# Create role for lambda
########################

resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

##########################
# Create a lambda function
##########################

resource "aws_lambda_function" "greet_lambda" {
    function_name   = "greet_lambda"
 
    filename        = data.archive_file.zip.output_path
    handler         = "greet_lambda.lambda_handler"
    source_code_hash = data.archive_file.zip.output_base64sha256
    role            = aws_iam_role.iam_for_lambda.arn
    runtime         = "python3.6"
    memory_size     = 128
    timeout         = 1

    environment {
    variables = {
      greeting = "Hello"
    }
  }
}

resource "aws_cloudwatch_log_group" "lambda_wg" {
    name            = "the_watch_group"
    retention_in_days = 14
}

# create policy: AWSLambdaBasicExecutionRole
resource "aws_iam_policy" "lambda_logging" {
    name            = "lambda_logging"
    path            = "/"
    description     = "IAM policy for logging from lambda"

    policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.lambda_logging.arn
}



# Permission for CloudWatch
resource "aws_lambda_permission" "cloudwatch" {
    statement_id    = "AllowExecutionFromCloudWatch"
    action          = "lambda:InvokeFunction"
    function_name   = aws_lambda_function.greet_lambda.function_name
    principal       = "events.amazonaws.com"
    source_arn      = "arn:aws:events:eu-west-1:111122223333:rule/RunDaily"
}