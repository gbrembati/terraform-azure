terraform {
  required_providers {
    dome9 = {
      source = "dome9/dome9"
      version = "1.20.5"
    }
  }
}

# API credentials to connect to your CSPM account
provider "dome9" {
  dome9_access_id     = "${var.cspm-key-id}"
  dome9_secret_key    = "${var.cspm-key-secret}"
}

# Create a dedicated Org-unit under the root one
resource "dome9_organizational_unit" "my-org-unit" {
  name      = var.cspm-org-unit
# parent_id = "00000000-0000-0000-0000-000000000000"
}

# Onboarding of your Azure Accounts
resource "dome9_cloudaccount_azure" "onboard-az-account" {
  count = length(var.azure-accounts)

  name                   = "${lookup(var.azure-accounts, count.index)[0]}"
  operation_mode         = var.azure-op-mode
  subscription_id        = "${lookup(var.azure-accounts, count.index)[1]}"
  tenant_id              = "${lookup(var.azure-accounts, count.index)[2]}"
  client_id              = "${lookup(var.azure-accounts, count.index)[3]}"
  client_password        = "${lookup(var.azure-accounts, count.index)[4]}"
  organizational_unit_id = dome9_organizational_unit.my-org-unit.id
}
