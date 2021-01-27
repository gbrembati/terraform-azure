# Set in this file your deployment variables
cspm-key-id     = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
cspm-key-secret = "xxxxxxxxxxxxxxxxxxxx"

cspm-org-unit   = "My Organization Unit"

azure-onboard   = true
azure-op-mode   = "Read"
azure-accounts  =  {
    "0" = ["NAME","SUBSCRIPTION ID","TENANT ID","CLIENT ID","CLIENT PASSWORD"]
#   "1" = ["NAME","SUBSCRIPTION ID","TENANT ID","CLIENT ID","CLIENT PASSWORD"]
#   "2" = ["NAME","SUBSCRIPTION ID","TENANT ID","CLIENT ID","CLIENT PASSWORD"]
  }

aws-onboard   = true
aws-op-mode   = "ReadOnly"
aws-accounts  = {
        "0" = ["NAME","ARN","SECRET"]
#       "1" = ["NAME","ARN","SECRET"]
#       "2" = ["NAME","ARN","SECRET"]        
    }

k8s-onboard   = true
k8s-clusters  = {
        "0" = "K8s-Cluster-1"
#       "1" = "K8s-Cluster-2"
#       "2" = "K8s-Cluster-3"
    }
