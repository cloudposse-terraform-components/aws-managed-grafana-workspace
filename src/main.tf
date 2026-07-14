locals {
  enabled = module.this.enabled

  additional_allowed_roles = compact(concat(
    [for prometheus in module.prometheus : prometheus.outputs.access_role_arn],
    var.additional_allowed_role_arns
  ))
}

module "security_group" {
  source  = "cloudposse/security-group/aws"
  version = "2.2.0"

  enabled = local.enabled && var.private_network_access_enabled

  allow_all_egress = true
  rules            = []
  vpc_id           = module.vpc.outputs.vpc_id

  context = module.this.context
}

module "managed_grafana" {
  source  = "cloudposse/managed-grafana/aws"
  version = "0.6.0"

  enabled = local.enabled

  authentication_providers  = var.authentication_providers
  permission_type           = var.permission_type
  account_access_type       = var.account_access_type
  organizational_units      = var.organizational_units
  data_sources              = var.data_sources
  grafana_version           = var.grafana_version
  configuration             = var.configuration
  prometheus_policy_enabled = var.prometheus_policy_enabled
  additional_allowed_roles  = local.additional_allowed_roles

  vpc_configuration = var.private_network_access_enabled ? {
    subnet_ids         = module.vpc.outputs.private_subnet_ids
    security_group_ids = [module.security_group.id]
  } : null

  context = module.this.context
}

resource "aws_grafana_role_association" "sso" {
  for_each = local.enabled ? {
    for association in var.sso_role_associations : association.role => association
  } : {}

  role      = each.value.role
  group_ids = each.value.group_ids
  user_ids  = each.value.user_ids

  workspace_id = module.managed_grafana.workspace_id
}
