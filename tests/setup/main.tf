provider "aws" {
}
resource "random_pet" "secret_managers_name" {
  length = 2
}

locals {
  secret_managers ={
    ebs_secret = {
        name = "terraform-${random_pet.secret_managers_name.id}",
        enable_rotation = false
        kms_key_id = "82fb2c43-7f54-44af-b602-05f1003bd767"
        replica = {}
        source_policy_documents = []
        override_policy_documents = []
        policy_statements = {}
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

output "secret_managers" {
    value = local.secret_managers
}

output "secret_manager_name" {
    value = "ebs_secret"
}