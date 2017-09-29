# giffgaff AWS Networking Module

This is a tool to generate the terraform remote state required to provide details about the network in an AWS account.

### Prerequisites

#### GNU Sed
On a mac, you'll need proper `sed`:

    brew install gnu-sed

#### Terraforming Gem

This ruby gem allows you to construct terraform files and state from existing AWS infrastructure.

    sudo gem install terraforming

### Usage

1. Authenticate with okta, using a PowerUser role in your chosen account
1. Run `./auto_import.sh`


The generated terraform should not be persisted back to this repo.


### Example Output
```
❯ ./auto_import.sh                                                                                                                                                  terraform-module-ggnetwork/git/master
Terraform Generation Complete
Now create a bucket in account 307482651216 called: 307482651216-terraform-state
WARNING: make sure you set it to the private ACL!!


Then run  terraform init
```

