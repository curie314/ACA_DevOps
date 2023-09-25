#!/bin/bash

echo "Running Terraform"

cd terraform 

terraform apply

echo "Fetching IP from output"

terraform output | awk -F'"' '/"/ {print $2}' >> /home/curie/git-final/ACA_DevOps/ansible/inventory.yml


echo "Running ansible"

cd ..

cd ansible

export ANSIBLE_HOST_KEY_CHECKING=False

ansible-playbook -i inventory.yml setup-wordpress.yml



