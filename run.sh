#!/bin/bash

echo "=== Starting Minecraft Server Deployment ==="

# Navigate to terraform directory
cd terraform

# Initialize and apply terraform
echo "=== Initializing Terraform ==="
terraform init

echo "=== Applying Terraform Configuration ==="
terraform apply -auto-approve

# Extract public IP from terraform output
echo "=== Extracting Public IP ==="
PUBLIC_IP=$(terraform output -raw instance_public_ip)
echo "Public IP: $PUBLIC_IP"

# Generate Ansible inventory file
echo "=== Generating Ansible Inventory ==="
cd ../ansible
cat > inventory.ini << EOF
[minecraft_servers]
minecraft_server ansible_host=$PUBLIC_IP ansible_user=ec2-user ansible_ssh_private_key_file=~/.ssh/minecraft-key
EOF

echo "Generated inventory.ini:"
cat inventory.ini

# Run Ansible playbook
echo "=== Running Ansible Playbook ==="
~/.ansible-venv/bin/ansible-playbook -i inventory.ini install_minecraft.yml

echo "=== Deployment Complete ==="
echo "Minecraft server should be running at: $PUBLIC_IP:25565"
