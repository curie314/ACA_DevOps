#!/bin/bash

export ANSIBLE_HOST_KEY_CHECKING=False


echo "Running Terraform"

cd terraform 

terraform apply

echo "Fetching IP from output"

terraform output | awk -F'"' '/"/ {print $2}' | head -n 1 >> ../ansible/inventory.yml

RDS_IP=$(terraform output | awk -F'"' 'NR==2 {print $2}')

echo "Running ansible"

cd ..

cd ansible

export ANSIBLE_HOST_KEY_CHECKING=False

ansible-playbook -i inventory.yml setup-wordpress.yml --extra-vars=MYSQL_HOSTNAME=$(RDS_IP)


