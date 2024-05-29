# AWS Secrets Manager Terraform module

Terraform module which creates AWS Secrets Manager resources.


### Standard

```hcl
module "secrets_manager" {
  source = "terraform-aws-modules/secrets-manager/aws"

  # Secret
  name_prefix             = "example"
  description             = "Example Secrets Manager secret"
  recovery_window_in_days = 30

  # Policy
  create_policy       = true
  block_public_policy = true
  policy_statements = {
    read = {
      sid = "AllowAccountRead"
      principals = [{
        type        = "AWS"
        identifiers = ["arn:aws:iam::1234567890:root"]
      }]
      actions   = ["secretsmanager:GetSecretValue"]
      resources = ["*"]
    }
  }

  # Version
  create_random_password           = true
  random_password_length           = 64
  random_password_override_special = "!@#$%^&*()_+"

  tags = {
    Environment = "Development"
    Project     = "Example"
  }
}
```

### w/ Rotation

```hcl
module "secrets_manager" {
  source = "terraform-aws-modules/secrets-manager/aws"

  # Secret
  name_prefix             = "rotated-example"
  description             = "Rotated example Secrets Manager secret"
  recovery_window_in_days = 7

  # Policy
  create_policy       = true
  block_public_policy = true
  policy_statements = {
    lambda = {
      sid = "LambdaReadWrite"
      principals = [{
        type        = "AWS"
        identifiers = ["arn:aws:iam:1234567890:role/lambda-function"]
      }]
      actions = [
        "secretsmanager:DescribeSecret",
        "secretsmanager:GetSecretValue",
        "secretsmanager:PutSecretValue",
        "secretsmanager:UpdateSecretVersionStage",
      ]
      resources = ["*"]
    }
    read = {
      sid = "AllowAccountRead"
      principals = [{
        type        = "AWS"
        identifiers = ["arn:aws:iam::1234567890:root"]
      }]
      actions   = ["secretsmanager:DescribeSecret"]
      resources = ["*"]
    }
  }

  # Version
  ignore_secret_changes = true
  secret_string = jsonencode({
    engine   = "mariadb",
    host     = "mydb.cluster-123456789012.us-east-1.rds.amazonaws.com",
    username = "Bill",
    password = "Initial"
    dbname   = "ThisIsMySuperSecretString12356!&*()",
    port     = 3306
  })

  # Rotation
  enable_rotation     = true
  rotation_lambda_arn = "arn:aws:lambda:us-east-1:123456789012:function:my-function"
  rotation_rules = {
    # This should be more sensible in production
    schedule_expression = "rate(1 minute)"
  }

  tags = {
    Environment = "Development"
    Project     = "Example"
  }
}
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0 |
| <a name="provider_random"></a> [random](#provider\_random) | >= 3.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_secretsmanager_secret](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_policy) | resource |
| [aws_secretsmanager_secret_rotation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_rotation) | resource |
 [aws_iam_policy_document](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_block_public_policy"></a> [block\_public\_policy](#input\_block\_public\_policy) | Makes an optional API call to Zelkova to validate the Resource Policy to prevent broad access to your secret | `bool` | `null` | no |
| <a name="input_description"></a> [description](#input\_description) | A description of the secret | `string` | `null` | no |
| <a name="input_enable_rotation"></a> [enable\_rotation](#input\_enable\_rotation) | Determines whether secret rotation is enabled | `bool` | `false` | no |
| <a name="input_force_overwrite_replica_secret"></a> [force\_overwrite\_replica\_secret](#input\_force\_overwrite\_replica\_secret) | Accepts boolean value to specify whether to overwrite a secret with the same name in the destination Region | `bool` | `null` | no |
| <a name="input_kms_key_id"></a> [kms\_key\_id](#input\_kms\_key\_id) | ARN or Id of the AWS KMS key to be used to encrypt the secret values in the versions stored in this secret. If you need to reference a CMK in a different account, you can use only the key ARN. If you don't specify this value, then Secrets Manager defaults to using the AWS account's default KMS key (the one named `aws/secretsmanager` | `string` | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | Friendly name of the new secret. The secret name can consist of uppercase letters, lowercase letters, digits, and any of the following characters: `/_+=.@-` | `string` | `null` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Creates a unique name beginning with the specified prefix | `string` | `null` | no |
| <a name="input_override_policy_documents"></a> [override\_policy\_documents](#input\_override\_policy\_documents) | List of IAM policy documents that are merged together into the exported document. In merging, statements with non-blank `sid`s will override statements with the same `sid` | `list(string)` | `[]` | no |
| <a name="input_policy_statements"></a> [policy\_statements](#input\_policy\_statements) | A map of IAM policy [statements](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document#statement) for custom permission usage | `map(any)` | `{}` | no |
| <a name="input_recovery_window_in_days"></a> [recovery\_window\_in\_days](#input\_recovery\_window\_in\_days) | Number of days that AWS Secrets Manager waits before it can delete the secret. This value can be `0` to force deletion without recovery or range from `7` to `30` days. The default value is `30` | `number` | `null` | no |
| <a name="input_replica"></a> [replica](#input\_replica) | Configuration block to support secret replication | `map(any)` | `{}` | no |
| <a name="input_rotation_lambda_arn"></a> [rotation\_lambda\_arn](#input\_rotation\_lambda\_arn) | Specifies the ARN of the Lambda function that can rotate the secret | `string` | `""` | no |
| <a name="input_rotation_rules"></a> [rotation\_rules](#input\_rotation\_rules) | A structure that defines the rotation configuration for this secret | `map(any)` | `{}` | no |
| <a name="input_source_policy_documents"></a> [source\_policy\_documents](#input\_source\_policy\_documents) | List of IAM policy documents that are merged together into the exported document. Statements must have unique `sid`s | `list(string)` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to secret manager resources | `map(string)` | `{}` | no |
| <a name="input_shared_tags"></a> [tags](#input\_tags) | A map of shared tags to add to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_secret_arn"></a> [secret\_arn](#output\_secret\_arn) | The ARN of the secret |
| <a name="output_secret_id"></a> [secret\_id](#output\_secret\_id) | The ID of the secret |
| <a name="output_secret_name"></a> [secret\_replica](#output\_secret\_replica) | The Name of the secret |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
