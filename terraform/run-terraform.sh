#!/bin/bash

terraform output | awk -F'"' '/"/ {print $2}' | head -n 1 >> ../ansible/inventory.yml

RDS_IP=$(terraform output | awk -F'"' 'NR==2 {print $2}')

echo "RDS_IP=$RDS_IP" >> $GITHUB_ENV

