variable "region" {
  type        = string
  description = "AWS Region"
}

variable "sso_role_associations" {
  type = list(object({
    role      = string
    group_ids = list(string)
  }))
  description = "A list of role to group ID list associations for granting Amazon Grafana access"
  default     = []
}

variable "prometheus_policy_enabled" {
  type        = bool
  description = "Set this to `true` to allow this Grafana workspace to access Amazon Managed Prometheus in this account"
  default     = false
}

variable "prometheus_source_accounts" {
  type = list(object({
    component   = optional(string, "managed-prometheus/workspace")
    stage       = string
    tenant      = optional(string, "")
    environment = optional(string, "")
  }))
  description = "A list of objects that describe an account where Amazon Managed Prometheus is deployed. This component grants this Grafana IAM role permission to assume the Prometheus access role in that target account. Use this for cross-account access"
  default     = []
}


variable "additional_allowed_role_arns" {
  type        = list(string)
  description = "A list of IAM role ARNs that the Grafana workspace role should be allowed to assume. Use this for cross-account access to services like CloudWatch"
  default     = []
}

variable "private_network_access_enabled" {
  type        = bool
  description = "If set to `true`, enable the VPC Configuration to allow this workspace to access the private network using outputs from the vpc component"
  default     = false
}

variable "workspace_configuration" {
  type        = string
  description = <<-EOT
    JSON string passed through to `aws_grafana_workspace.configuration`.
    Most commonly used to flip the workspace from legacy alerting to
    Grafana unified alerting permanently:

      workspace_configuration = jsonencode({
        unifiedAlerting = { enabled = true }
        plugins         = { pluginAdminEnabled = false }
      })

    Without this, AMG runs in legacy alerting mode and any unified-alerting
    resources provisioned via the Grafana API exist but are never evaluated
    by the running engine. See:
    https://docs.aws.amazon.com/grafana/latest/userguide/AMG-configure-workspace.html
  EOT
  default     = null
}

variable "grafana_version" {
  type        = string
  description = <<-EOT
    Pin the Grafana major version supported by the workspace. Supported AMG
    values include `9.4`, `10.4`, `12.4`. Leave null to follow AMG's
    latest-supported default.
  EOT
  default     = null
}
