#!/bin/bash

terraforming  vpc --region eu-west-1 --profile default > vpc.tf
terraforming  sn  --region eu-west-1 --profile default > sn.tf
terraforming  sn --tfstate --region eu-west-1 --profile default > sn.tfstate
terraforming vpc --tfstate --region eu-west-1 --profile default  --merge ./sn.tfstate > terraform.tfstate

rm sn.tfstate
sed -i .bak '/aws\:/d' sn.tf && rm sn.tf.bak
sed -i .bak '/aws\:/d' vpc.tf && rm vpc.tf.bak
touch output.tf
cat /dev/null > output.tf

cat <<EOF > provider.tf
provider "aws" {
  region = "eu-west-1"
}
EOF

function output {
  resourceID=$1
  outputName=$2
  cat <<EOF >> output.tf
output "$outputName" {
  value="\${aws_subnet.$resourceID.id}"
}
EOF
}


function vpc_output {
  resourceID=$1
    cat <<EOF >> output.tf
output "vpc_id" {
  value="\${aws_vpc.$resourceID.id}"
}
EOF
}

function UCC_to_kebab {
  echo $1 | gsed -e 's/\([A-Z0-9]\)/_\L\1/g' -e 's/^_//'
}

for resource in $(grep "resource " ./sn.tf | awk '{print $3}'| sed 's|"||g'); do
  resourceEnd=$(echo $resource | awk 'BEGIN { FS = "-" } ; { print $5 }')
  output $resource $(UCC_to_kebab $resourceEnd)
done

for vpc in $(grep "resource " ./vpc.tf | awk '{print $3}'| sed 's|"||g'); do
  vpc_output $vpc
done

statebucket=$(aws sts get-caller-identity --output text --query 'Account')-terraform-state
cat <<EOF > terraform.tf

terraform {
  backend "s3" {
    bucket = "$statebucket"
    key    = "network"
    region = "eu-west-1"
  }
}
EOF
RED='\033[0;33m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color
account=$(aws sts get-caller-identity --output text --query 'Account')
echo -e "Terraform Generation Complete"
echo -e "Now create a bucket in account $account called: ${GREEN}$statebucket${NC}"
echo -e "${RED}WARNING${NC}: make sure you set it to the private ACL!!"
echo -e "\n"
echo -e "Then run  ${GREEN}terraform init${NC}"