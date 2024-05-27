locals {
  # Filter the secret managers to include only those that are enabled for key rotation
  secrets_manager_enabled_rotation = {
    for key, secret_manager in var.secret_managers : key => secret_manager
    if secret_manager.enable_rotation
  }
}

# Create Secrets Managers
resource "aws_secretsmanager_secret" "sm" {
  for_each = var.secret_managers

  description                    = each.value.description
  force_overwrite_replica_secret = each.value.force_overwrite_replica_secret
  kms_key_id                     = each.value.kms_key_id
  name                           = each.value.name
  name_prefix                    = each.value.name_prefix
  recovery_window_in_days        = each.value.recovery_window_in_days
  
  dynamic "replica" {
    for_each = each.value.replica

    content {
      kms_key_id = try(replica.value.kms_key_id, null)
      region     = try(replica.value.region, replica.key)
    }
  }

  tags = var.tags
}


################################################################################
# Policy
################################################################################

data "aws_iam_policy_document" "secret_manager_iam_policy_data" {
  for_each = var.secret_managers

  source_policy_documents   = each.value.source_policy_documents
  override_policy_documents = each.value.override_policy_documents

  dynamic "statement" {
    for_each = each.value.policy_statements

    content {
      sid           = try(statement.value.sid, null)
      actions       = try(statement.value.actions, null)
      not_actions   = try(statement.value.not_actions, null)
      effect        = try(statement.value.effect, null)
      resources     = try(statement.value.resources, null)
      not_resources = try(statement.value.not_resources, null)

      dynamic "principals" {
        for_each = try(statement.value.principals, [])

        content {
          type        = principals.value.type
          identifiers = principals.value.identifiers
        }
      }

      dynamic "not_principals" {
        for_each = try(statement.value.not_principals, [])

        content {
          type        = not_principals.value.type
          identifiers = not_principals.value.identifiers
        }
      }

      dynamic "condition" {
        for_each = try(statement.value.conditions, [])

        content {
          test     = condition.value.test
          values   = condition.value.values
          variable = condition.value.variable
        }
      }
    }
  }
}

resource "aws_secretsmanager_secret_policy" "secret_manager_policy" {
  for_each = aws_secretsmanager_secret.sm

  secret_arn          = each.value.arn
  policy              = data.aws_iam_policy_document.secret_manager_iam_policy_data[each.key].json
  block_public_policy = var.block_public_policy
}

################################################################################
# Rotation
################################################################################

resource "aws_secretsmanager_secret_rotation" "secrets_rotation" {
  for_each = local.secrets_manager_enabled_rotation
 
  rotation_lambda_arn = each.value.rotation_lambda_arn

  dynamic "rotation_rules" {
    for_each = [each.value.rotation_rules]

    content {
      automatically_after_days = try(rotation_rules.value.automatically_after_days, null)
      duration                 = try(rotation_rules.value.duration, null)
      schedule_expression      = try(rotation_rules.value.schedule_expression, null)
    }
  }
  secret_id = aws_secretsmanager_secret.sm[each.key].id
}

