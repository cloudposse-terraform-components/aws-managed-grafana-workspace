variable "region" {
  type        = string
  description = "AWS Region"
}

variable "sso_role_associations" {
  type = list(object({
    role      = string
    group_ids = optional(list(string), [])
    user_ids  = optional(list(string), [])
  }))
  description = "A list of role to group ID and user ID list associations for granting Amazon Grafana access. Only used when `var.authentication_providers` includes `AWS_SSO`."
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

variable "authentication_providers" {
  type        = list(string)
  description = "The authentication providers for the workspace. Valid values are `AWS_SSO`, `SAML`, or both."
  default     = ["AWS_SSO"]
}

variable "permission_type" {
  type        = string
  description = "The permission type of the workspace. `SERVICE_MANAGED` generates the IAM role and policy attachments automatically; `CUSTOMER_MANAGED` does not."
  default     = "SERVICE_MANAGED"
}

variable "account_access_type" {
  type        = string
  description = "The type of account access for the workspace. Valid values are `CURRENT_ACCOUNT` and `ORGANIZATION`. If `ORGANIZATION` is specified, `organizational_units` must also be present."
  default     = "CURRENT_ACCOUNT"
  validation {
    condition     = contains(["CURRENT_ACCOUNT", "ORGANIZATION"], var.account_access_type)
    error_message = "account_access_type must be either CURRENT_ACCOUNT or ORGANIZATION"
  }
}

variable "organizational_units" {
  type        = list(string)
  description = "A list of organizational unit (OU) IDs to grant the workspace access to. Only used when `var.account_access_type` is `ORGANIZATION`."
  default     = []
}

variable "data_sources" {
  type        = list(string)
  description = "The data sources for the workspace. Valid values include AMAZON_OPENSEARCH_SERVICE, ATHENA, CLOUDWATCH, PROMETHEUS, REDSHIFT, SITEWISE, TIMESTREAM, XRAY."
  default     = []
}

variable "configuration" {
  type        = string
  description = "JSON string containing the workspace configuration. Use to enable Grafana unified alerting (`{\"unifiedAlerting\":{\"enabled\":true}}`) and/or plugin management (`{\"plugins\":{\"pluginAdminEnabled\":true}}`)."
  default     = null
}

variable "grafana_version" {
  type        = string
  description = "The version of Grafana to support in the workspace (e.g. `9.4`, `10.4`, `12.4`). If not specified, AMG defaults to the latest supported version."
  default     = null
}
