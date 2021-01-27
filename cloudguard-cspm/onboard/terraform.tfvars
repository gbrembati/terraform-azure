# Set in this file your deployment variables
cspm-key-id     = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
cspm-key-secret = "xxxxxxxxxxxxxxxxxxxx"

cspm-org-unit   = "My Organization Unit"

azure-op-mode   = "Read-Only"
azure-accounts  =  {
    "0" = ["NAME","SUBSCRIPTION ID","TENANT ID","CLIENT ID","CLIENT PASSWORD"]
#   "1" = ["NAME","SUBSCRIPTION ID","TENANT ID","CLIENT ID","CLIENT PASSWORD"]
#   "2" = ["NAME","SUBSCRIPTION ID","TENANT ID","CLIENT ID","CLIENT PASSWORD"]
  }

aws-op-mode   = "ReadOnly"
aws-accounts = {
        "0" = ["NAME","ARN","SECRET"]
#       "1" = ["NAME","ARN","SECRET"]
#       "2" = ["NAME","ARN","SECRET"]        
    }