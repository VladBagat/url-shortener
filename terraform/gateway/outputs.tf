output "api_id" {
  value = aws_apigatewayv2_api.gateway.id
}

output "api_endpoint" {
  value = aws_apigatewayv2_api.gateway.api_endpoint
}

output "stage_name" {
  value = aws_apigatewayv2_stage.default.name
}

output "custom_domain_name" {
  value = aws_apigatewayv2_domain_name.custom_domain.domain_name
}

output "custom_domain_target_domain_name" {
  value = aws_apigatewayv2_domain_name.custom_domain.domain_name_configuration[0].target_domain_name
}

output "custom_domain_hosted_zone_id" {
  value = aws_apigatewayv2_domain_name.custom_domain.domain_name_configuration[0].hosted_zone_id
}
