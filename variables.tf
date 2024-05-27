

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "secret_managers" {
  description = "A map of all secret managers"
  type = map(object({
    name = string
    description = optional(string)
    force_overwrite_replica_secret = optional(bool)
    kms_key_id = optional(string)
    name_prefix = optional(string)
    recovery_window_in_days = optional(number)
    replica = map(any)
    source_policy_documents = list(string)
    override_policy_documents = list(string)
    policy_statements = map(any)
    block_public_policy = optional(bool)
    enable_rotation = bool
    rotation_lambda_arn = string
    rotation_rules = map(any)
  }))
  default = {
    ebs_secret = {
      name = "ebs_secret"
      description = null
      force_overwrite_replica_secret = null
      kms_key_id = null
      name_prefix = null
      recovery_window_in_days = null
      replica = {}
      source_policy_documents = []
      override_policy_documents = []
      policy_statements = {
        "allow_read_from_vpc" = {
      sid = "AllowReadFromVPC"
      principals = [
        {
          type = "IAMRole"
          identifiers = ["arn:aws:iam::123456789012:role/some-role"]
        }
      ]
      actions = ["secretsmanager:GetSecretValue"]
      resources = ["*"]
    }}
      block_public_policy = null
      enable_rotation = false
      rotation_lambda_arn = ""
      rotation_rules = {}
    }
  }
}


variable "block_public_policy" {
  description = "Makes an optional API call to Zelkova to validate the Resource Policy to prevent broad access to your secret"
  type        = bool
  default     = null
}



