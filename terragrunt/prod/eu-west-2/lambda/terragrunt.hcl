include "root" {
  path   = find_in_parent_folders("terragrunt.hcl")
  expose = true
}

terraform {
  source = "../../../../terraform/lambda"
}

dependency "dynamodb" {
  config_path = "../dynamodb"
}

locals {
  shorten_function_name  = "shorten-${include.root.locals.environment}"
  redirect_function_name = "redirect-${include.root.locals.environment}"
  shorten_role_name      = "shorten_lambda_dynamo_${include.root.locals.environment}"
  redirect_role_name     = "redirect_lambda_dynamo_${include.root.locals.environment}"
  shorten_policy_name    = "shorten-lambda-dynamodb-policy-${include.root.locals.environment}"
  redirect_policy_name   = "redirect-lambda-dynamodb-policy-${include.root.locals.environment}"
}

inputs = {
  dynamodb_table_name                     = dependency.dynamodb.outputs.table_name
  dynamodb_table_arn                      = dependency.dynamodb.outputs.table_arn
  dynamodb_short_code_key                 = dependency.dynamodb.outputs.short_code_key
  shorten_function_name                   = local.shorten_function_name
  redirect_function_name                  = local.redirect_function_name
  shorten_role_name                       = local.shorten_role_name
  redirect_role_name                      = local.redirect_role_name
  shorten_policy_name                     = local.shorten_policy_name
  redirect_policy_name                    = local.redirect_policy_name
  shorten_lambda_source_file              = "${get_terragrunt_dir()}/../../../../lambdas/shorten/index.py"
  redirect_lambda_source_file             = "${get_terragrunt_dir()}/../../../../lambdas/redirect/index.py"
  redirect_path_parameter_name            = "short_code"
  shorten_reserved_concurrent_executions  = -1
  redirect_reserved_concurrent_executions = -1
}
