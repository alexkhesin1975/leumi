resource "aws_api_gateway_rest_api" "leumiexam" {
  name        = "Leumi-Lambda-Exam"
  description = "The Gateway for Leumi Lambda exam"
}

resource "aws_api_gateway_integration" "lambda" {
  rest_api_id = "${aws_api_gateway_rest_api.leumiexam.id}"
  resource_id = "${aws_api_gateway_method.proxy.resource_id}"
  http_method = "${aws_api_gateway_method.proxy.http_method}"

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.leumiexam.invoke_arn}"
}

resource "aws_api_gateway_method" "proxy_root" {
  rest_api_id   = "${aws_api_gateway_rest_api.leumiexam.id}"
  resource_id   = "${aws_api_gateway_rest_api.leumiexam.root_resource_id}"
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_root" {
  rest_api_id = "${aws_api_gateway_rest_api.leumiexam.id}"
  resource_id = "${aws_api_gateway_method.proxy_root.resource_id}"
  http_method = "${aws_api_gateway_method.proxy_root.http_method}"

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.leumiexam.invoke_arn}"
}

resource "aws_api_gateway_deployment" "leumiexam" {
  depends_on = [
    "aws_api_gateway_integration.lambda",
    "aws_api_gateway_integration.lambda_root",
  ]

  rest_api_id = "${aws_api_gateway_rest_api.leumiexam.id}"
  stage_name  = "test"
}

output "base_url" {
  value = "${aws_api_gateway_deployment.leumiexam.invoke_url}"
}