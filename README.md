# giffgaff AWS Networking Module

This repsitory contains a tool to extract the IDs of network infrastrcuture from giffgaff AWS accounts into a terraform s3 backend, so that they can be referenced by other terraform modules.


THe AWS Accounts at giffgaff are set up by the DES team in a standard format:


One VPC, connected via site to site VPN.
6 Subnets, in two availbility zones:

| AZ A                   | AZ B                  |
| ---------------------- | --------------------- |
| public\_1\_subnet\_a   | public\_1\_subnet\_b  |
| private\_1\_subnet\_a  | private\_1\_subnet\_b |
| private\_2\_subnet\_a  | private\_1\_subnet\_b |




## Prerequisites

#### GNU Sed
On a mac, you'll need proper `sed`:

    brew install gnu-sed

#### Terraforming Gem

This ruby gem allows you to construct terraform files and state from existing AWS infrastructure.

    sudo gem install terraforming

## Usage

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


### Using state from this tool

First - set the bucket up as a remote state data source:
```
data "terraform_remote_state" "network" {
  backend = "s3"

  config {
    bucket = "${data.aws_caller_identity.current.account_id}-terraform-state"
    key    = "network/terraform.tfstate"
    region = "eu-west-1"
  }
}
```

Then the outputs of this module can be referenced like this:

`${data.terraform_remote_state.network.vpc_id}`
or
`${data.terraform_remote_state.network.private_1_subnet_a}`


