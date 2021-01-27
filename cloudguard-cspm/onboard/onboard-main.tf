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
  dome9_access_id   = var.cspm-key-id
  dome9_secret_key  = var.cspm-key-secret
}

# Create a dedicated Org-unit under the root one
resource "dome9_organizational_unit" "my-org-unit" {
  name      = var.cspm-org-unit
# parent_id = "00000000-0000-0000-0000-000000000000"
}

# Onboarding of your Azure Accounts
resource "dome9_cloudaccount_azure" "onboard-az-account" {
  count = var.azure-onboard ? length(var.azure-accounts) : 0

  name                   = lookup(var.azure-accounts, count.index)[0]
  operation_mode         = var.azure-op-mode
  subscription_id        = lookup(var.azure-accounts, count.index)[1]
  tenant_id              = lookup(var.azure-accounts, count.index)[2]
  client_id              = lookup(var.azure-accounts, count.index)[3]
  client_password        = lookup(var.azure-accounts, count.index)[4]
  organizational_unit_id = dome9_organizational_unit.my-org-unit.id

  depends_on = [dome9_organizational_unit.my-org-unit]
}

# Onboarding of your AWS Accounts
resource "dome9_cloudaccount_AWS" "onboard-aws-account" {
  count = var.aws-onboard ? length(var.aws-accounts) : 0
  
  name  = lookup(var.aws-accounts, count.index)[0]
  credentials  {
    ARN    = lookup(var.aws-accounts, count.index)[1]
    secret = lookup(var.aws-accounts, count.index)[2]
    type   = "RoleBased"
  }
  organizational_unit_id = dome9_organizational_unit.my-org-unit.id

  net_sec {
    regions {
      new_group_behavior = var.aws-op-mode
      region             = "us_east_1"
    }
    regions {
      new_group_behavior = var.aws-op-mode
      region             = "us_west_1"
    }
    regions {
      new_group_behavior = var.aws-op-mode
      region             = "eu_west_1"
    }
    regions {
      new_group_behavior = var.aws-op-mode
      region             = "ap_southeast_1"
    }
    regions {
      new_group_behavior = var.aws-op-mode
      region             = "ap_northeast_1"
    }
    regions {
      new_group_behavior = var.aws-op-mode
      region             = "us_west_2"
    }
    regions {
      new_group_behavior = var.aws-op-mode
      region             = "sa_east_1"
    }
    regions {
      new_group_behavior = var.aws-op-mode
      region             = "ap_southeast_2"
    }
    regions {
      new_group_behavior = var.aws-op-mode
      region             = "eu_central_1"
    }
    regions {
      new_group_behavior = var.aws-op-mode
      region             = "ap_northeast_2"
    }
    regions {
      new_group_behavior = var.aws-op-mode
      region             = "ap_south_1"
    }
    regions {
      new_group_behavior = var.aws-op-mode
      region             = "us_east_2"
    }
    regions {
      new_group_behavior = var.aws-op-mode
      region             = "ca_central_1"
    }
    regions {
      new_group_behavior = var.aws-op-mode
      region             = "eu_west_2"
    }
    regions {
      new_group_behavior = var.aws-op-mode
      region             = "eu_west_3"
    }
    regions {
      new_group_behavior = var.aws-op-mode
      region             = "eu_north_1"
    }
    regions {
      new_group_behavior = var.aws-op-mode
      region             = "ap_east_1"
    }
    regions {
      new_group_behavior = var.aws-op-mode
      region             = "me_south_1"
    }
    regions {
      new_group_behavior = var.aws-op-mode
      region             = "af_south_1"
    }
    regions {
      new_group_behavior = var.aws-op-mode
      region             = "eu_south_1"
    }
  }
  depends_on = [dome9_organizational_unit.my-org-unit]
}
