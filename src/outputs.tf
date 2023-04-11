output "base_url" {
  description = "Base URL for API Gateway"
  value       = "${aws_api_gateway_deployment.test_API_deployment.invoke_url}"
  
}

output "lambda_function" {
	value = aws_lambda_function.terraform_form.qualified_arn
}