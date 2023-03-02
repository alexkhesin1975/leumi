provider "aws" {
  region = "us-east-1"
}

resource "aws_lambda_function" "leumiexam" {
  function_name = "LeumiLambdaExam"

  s3_bucket = "Leumi-Lambda-Exam-s3"
  s3_key    = "leumi_exam.zip"

  handler = "main.handler"
  runtime = "nodejs8.10"

  role = "${aws_iam_role.lambda_exec.arn}"
}

resource "aws_api_gateway_resource" "proxy" {
  rest_api_id = "${aws_api_gateway_rest_api.leumiexam.id}"
  parent_id   = "${aws_api_gateway_rest_api.leumiexam.root_resource_id}"
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "proxy" {
  rest_api_id   = "${aws_api_gateway_rest_api.leumiexam.id}"
  resource_id   = "${aws_api_gateway_resource.proxy.id}"
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.leumiexam.function_name}"
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.leumiexam.execution_arn}/*/*"
}

resource "aws_iam_role" "lambda_exec" {
  name = "Leumi-Lambda-Exam"

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