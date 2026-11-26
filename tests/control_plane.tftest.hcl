mock_provider "aws" {}

variables {
  environment = "qa"
  subnet_ids  = ["subnet-00000000000000001", "subnet-00000000000000002"]
}

run "qa_private_control_plane" {
  command = plan
  assert {
    condition     = output.cluster_name == "portfolio-qa"
    error_message = "QA must use an isolated name."
  }
  assert {
    condition     = output.private_endpoint && !output.public_endpoint
    error_message = "Control plane must use private access."
  }
}

run "reject_invalid_environment" {
  command = plan
  variables { environment = "invalid" }
  expect_failures = [var.environment]
}

run "reject_single_subnet" {
  command = plan
  variables { subnet_ids = ["subnet-00000000000000001"] }
  expect_failures = [var.subnet_ids]
}
