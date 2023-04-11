

data "aws_iam_policy_document" "lambda_assume_role_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda_role" {
  name               = "lambda-lambdarole"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_policy.json

  inline_policy {
    name   = "allow_dynamodb"
    policy = file("dynamodbpolicy.json")
  }
}

resource "aws_lambda_function" "terraform_form" {
  function_name    = "form"
  filename         = data.archive_file.example_zip_file.output_path
  role             = aws_iam_role.lambda_role.arn
  runtime = "python3.8"
  handler = "form.lambda_handler"
  timeout          = 10

  tags = var.common_tags
}
resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.terraform_form.function_name}"
  principal     = "apigateway.amazonaws.com"

   # More: http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-control-access-using-iam-policies-to-invoke-api.html
  source_arn = "${aws_api_gateway_rest_api.test_API.execution_arn}/*/*"
  #source_arn = "arn:aws:execute-api:${var.my_region}:${var.account_ID}:${aws_api_gateway_rest_api.test_API.id}/*/${aws_api_gateway_method.test_API_method.http_method}${aws_api_gateway_resource.test_API_resource.path}"
}


