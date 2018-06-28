provider "aws" {
  region = "eu-west-2"
}

module "policies_json" {
  source = "git::https://github.com/firmstep-public/terraform-aws-ssm-parameter-store-policy-documents.git?ref=tags/0.1.1"
}

output "manage_json" {
  value = "${module.policies_json.manage_parameter_store_policy}"
}

resource "aws_iam_policy" "ps_manage" {
  name_prefix = "manage_any_parameter_store_value"
  path        = "/"
  policy      = "${module.policies_json.manage_parameter_store_policy}"
}
