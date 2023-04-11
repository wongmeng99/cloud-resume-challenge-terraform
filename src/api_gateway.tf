resource "aws_api_gateway_rest_api" "test_API" {
  name = "test_api"
  description = "This is for testing purpose with Terraform"
}

resource "aws_api_gateway_resource" "test_API_resource" {
  parent_id   = aws_api_gateway_rest_api.test_API.root_resource_id
  path_part   = "test"
  rest_api_id = aws_api_gateway_rest_api.test_API.id
}

resource "aws_api_gateway_method" "test_API_method" {
  authorization = "NONE"
  http_method   = "POST"
  resource_id   = aws_api_gateway_resource.test_API_resource.id
  rest_api_id   = aws_api_gateway_rest_api.test_API.id
}

resource "aws_api_gateway_integration" "test_API_integration" {
  http_method = aws_api_gateway_method.test_API_method.http_method
  resource_id = aws_api_gateway_resource.test_API_resource.id
  rest_api_id = aws_api_gateway_rest_api.test_API.id
  integration_http_method = "POST"
  type        = "LAMBDA"
  uri         = aws_lambda_function.terraform_form.invoke_arn
}

resource "aws_api_gateway_deployment" "test_API_deployment" {
  rest_api_id = aws_api_gateway_rest_api.test_API.id

  triggers = {
    # NOTE: The configuration below will satisfy ordering considerations,
    #       but not pick up all future REST API changes. More advanced patterns
    #       are possible, such as using the filesha1() function against the
    #       Terraform configuration file(s) or removing the .id references to
    #       calculate a hash against whole resources. Be aware that using whole
    #       resources will show a difference after the initial implementation.
    #       It will stabilize to only change when resources change afterwards.
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.test_API_resource.id,
      aws_api_gateway_method.test_API_method.id,
      aws_api_gateway_integration.test_API_integration.id,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "test_API_stage" {
  deployment_id = aws_api_gateway_deployment.test_API_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.test_API.id
  stage_name    = "test"
}

