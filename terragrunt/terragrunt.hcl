locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  region_vars  = read_terragrunt_config(find_in_parent_folders("region.hcl"))

  project_name = "url-shortener"
  aws_region   = local.region_vars.locals.aws_region
  account_name = local.account_vars.locals.account_name
  account_id   = local.account_vars.locals.aws_account_id
  environment  = local.account_vars.locals.environment
}

remote_state {
  backend = "s3"

  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }

  config = {
    bucket = "terraform-state-${local.project_name}-${local.account_id}-${local.aws_region}"

    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = local.aws_region
    encrypt        = true
    dynamodb_table = "terraform-locks-${local.project_name}-${local.account_name}"
  }
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
  provider "aws" {
  region = "${local.aws_region}"

  default_tags {
    tags = {
      Environment = "${local.environment}"
      Terraform   = "true"
    }
  }
}
EOF
}
