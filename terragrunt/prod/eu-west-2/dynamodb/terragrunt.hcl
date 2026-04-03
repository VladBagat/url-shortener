include "root" {
  path   = find_in_parent_folders("terragrunt.hcl")
  expose = true
}

terraform {
  source = "../../../../terraform/dynamodb"
}

inputs = {
  environment = include.root.locals.environment
}
