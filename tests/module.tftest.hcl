# setup module to create a input vairable for secret manager
run "setup_tests" {
    module {
        source = "./tests/setup"
    }
}

run "create_secret_manager" {
    command = plan
    variables {
        secret_managers = {
            ebs_secret = {
                name = run.setup_tests.secret_manager_name
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
        block_public_policy = false
    }
   
}

run "check_secret_manager_name" {
    variables {
        secret_managers = {
            ebs_secret = {
                name = run.setup_tests.secret_manager_name
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
        block_public_policy = false
    }
    assert {
        condition = run.setup_tests.secret_manager_name == aws_secretsmanager_secret.sm["ebs_secret"].name
        error_message = "secret manager name doesn't match"
    }
}

