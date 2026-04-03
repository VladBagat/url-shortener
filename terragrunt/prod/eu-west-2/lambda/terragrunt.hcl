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

inputs = {
  environment                             = include.root.locals.environment
  dynamodb_table_name                     = dependency.dynamodb.outputs.table_name
  dynamodb_table_arn                      = dependency.dynamodb.outputs.table_arn
  dynamodb_short_code_key                 = dependency.dynamodb.outputs.short_code_key
  shorten_lambda_source_file              = "${get_terragrunt_dir()}/../../../../lambdas/shorten/index.py"
  redirect_lambda_source_file             = "${get_terragrunt_dir()}/../../../../lambdas/redirect/index.py"
  redirect_path_parameter_name            = "short_code"
  shorten_reserved_concurrent_executions  = -1
  redirect_reserved_concurrent_executions = -1
}
