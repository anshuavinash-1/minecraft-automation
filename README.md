# Automated Minecraft Server Deployment on AWS

## Background

This project demonstrates a fully automated approach to deploying a Minecraft server on Amazon Web Services using modern DevOps practices. The solution was developed to showcase Infrastructure as Code (IaC) principles and configuration management automation.

### Project Goals
- Deploy a production-ready Minecraft server without manual AWS console interaction
- Demonstrate Infrastructure as Code using Terraform for resource provisioning
- Implement configuration management with Ansible for server setup
- Create a repeatable, version-controlled deployment pipeline

### Technical Approach
The deployment pipeline consists of three main phases:
1. **Infrastructure Provisioning**: Terraform creates and configures AWS resources
2. **Dynamic Configuration**: Automated inventory generation captures infrastructure outputs
3. **Server Configuration**: Ansible installs and configures the Minecraft server environment

## Requirements

### Software Dependencies

| Component | Version | Installation Method |
|-----------|---------|-------------------|
| Terraform | >= 1.0.0 | Package manager or direct download |
| Ansible Core | 2.17 | Python pip in virtual environment |
| AWS CLI | >= 2.0.0 | Official AWS installer |
| Python | >= 3.8 | System package manager |
| nmap | Latest | System package manager |

### System Requirements
- **Operating System**: Linux, macOS, or Windows with WSL2
- **Memory**: Minimum 4GB RAM for local tooling
- **Network**: Internet access for downloading dependencies
- **Storage**: 2GB free space for tools and temporary files

### Installation Guide

#### macOS Systems (Recommended for Development)
```bash
# Install Homebrew package manager (if not already installed)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install required tools using Homebrew
brew install terraform
brew install awscli
brew install nmap
brew install python@3.11

# Create Python virtual environment for Ansible
python3 -m venv ~/.ansible-venv
source ~/.ansible-venv/bin/activate
pip install --upgrade pip
pip install ansible-core==2.17

# Verify installations
terraform version
aws --version
ansible --version
nmap --version
```

#### Ubuntu/Debian Systems
```bash
# Update system packages
sudo apt update && sudo apt upgrade -y

# Install Terraform
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform

# Create Python virtual environment for Ansible
python3 -m venv ~/.ansible-venv
source ~/.ansible-venv/bin/activate
pip install --upgrade pip
pip install ansible-core==2.17

# Install AWS CLI v2
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Install network tools
sudo apt install nmap
```

#### RHEL/CentOS/Amazon Linux
```bash
# Install required packages
sudo yum update -y
sudo yum install -y python3 python3-pip unzip

# Install Terraform
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
sudo yum install terraform

# Setup Ansible environment
python3 -m venv ~/.ansible-venv
source ~/.ansible-venv/bin/activate
pip install ansible-core==2.17

# Install AWS CLI and tools
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
sudo yum install nmap
```

#### Windows Setup
```powershell
# Install using Chocolatey (run as Administrator)
Set-ExecutionPolicy Bypass -Scope Process -Force
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

# Install required software
choco install terraform awscli python nmap git

# Setup Ansible virtual environment
python -m venv %USERPROFILE%\.ansible-venv
%USERPROFILE%\.ansible-venv\Scripts\activate.bat
pip install ansible-core==2.17
```

### AWS Configuration

#### Authentication Methods
Choose one of these authentication approaches:

**Method 1: AWS CLI Configuration**
```bash
aws configure
# Provide: Access Key ID, Secret Access Key, Default region, Output format
```

**Method 2: Environment Variables**
```bash
export AWS_ACCESS_KEY_ID="your-access-key-id"
export AWS_SECRET_ACCESS_KEY="your-secret-access-key"
export AWS_DEFAULT_REGION="us-west-2"
```

**Method 3: AWS Learner Lab**
```bash
# Copy credentials from AWS Details section in Learner Lab
# Paste into ~/.aws/credentials file
```

#### Required IAM Permissions
Your AWS credentials must have these capabilities:
- EC2 instance management (launch, terminate, describe)
- Security group creation and modification
- VPC and subnet management
- Key pair creation and management
- Basic IAM permissions for resource tagging

## Architecture Overview

```
┌─────────────────┐
│     run.sh      │  ← Main orchestration script
│   Entry Point   │
└─────────┬───────┘
          │
          ▼
┌─────────────────┐    ┌──────────────────┐
│   Terraform     │───▶│  AWS Resources   │
│  Infrastructure │    │  • EC2 Instance  │
│   Provisioning  │    │  • Security Grp  │
└─────────┬───────┘    │  • VPC/Subnet    │
          │            │  • SSH Key Pair  │
          │            └──────────────────┘
          ▼
┌─────────────────┐
│  Dynamic IP     │
│   Extraction    │
└─────────┬───────┘
          │
          ▼
┌─────────────────┐    ┌──────────────────┐
│   Ansible       │───▶│  Server Config   │
│  Configuration  │    │  • Java 21 JDK   │
│   Management    │    │  • Minecraft JAR │
└─────────────────┘    │  • systemd Svc   │
                       └──────────────────┘
```

## Project Structure

```
minecraft-automation/
├── README.md                    # Project documentation
├── run.sh                      # Main deployment script
├── terraform/                  # Infrastructure code
│   ├── main.tf                # Resource definitions
│   ├── outputs.tf             # Generated values
└── ansible/                   # Configuration management
    ├── install_minecraft.yml  # Server setup playbook
    └── inventory.ini          # Auto-generated host file
```

## Deployment Process

### Phase 1: Initial Setup
```bash
# Clone project repository
git clone https://github.com/anshuavinash-1/minecraft-automation
cd minecraft-automation

# Configure execution permissions (macOS/Linux only)
chmod +x run.sh

# Verify tool installations
terraform version
ansible --version
aws --version

# Activate Ansible virtual environment
source ~/.ansible-venv/bin/activate
```


### Phase 2: Execute Deployment
```bash
# Ensure Ansible virtual environment is activated
source ~/.ansible-venv/bin/activate

# Run complete deployment pipeline
./run.sh
```

**Deployment Stages Explained:**

1. **Terraform Initialization**
   - Downloads required providers
   - Initializes backend state management
   - Validates configuration syntax

2. **Infrastructure Creation**
   - Provisions EC2 instance with specified configuration
   - Creates security groups with appropriate rules
   - Sets up networking components (VPC, subnet, gateway)
   - Generates SSH key pair for secure access

3. **IP Address Extraction**
   - Retrieves public IP from Terraform state
   - Validates successful resource creation
   - Prepares connection parameters

4. **Ansible Inventory Generation**
   - Creates dynamic inventory file
   - Configures SSH connection parameters
   - Validates host accessibility

5. **Server Configuration**
   - Installs Python 3 runtime environment
   - Downloads and configures Amazon Corretto 21 JDK
   - Downloads Minecraft server JAR (version 1.20.6)
   - Accepts End User License Agreement
   - Creates systemd service for automatic startup
   - Enables service for boot persistence

### Phase 4: Verification
```bash
# Retrieve server IP address
cd terraform
PUBLIC_IP=$(terraform output -raw instance_public_ip)
echo "Minecraft server IP: $PUBLIC_IP"

# Test server connectivity and service
nmap -sV -Pn -p T:25565 $PUBLIC_IP


## Connecting to Your Server

### Minecraft Client Connection
1. Launch Minecraft Java Edition
2. Navigate to Multiplayer section
3. Select "Add Server"
4. Configure server connection:
   - **Server Name**: `AWS Minecraft Server`
   - **Server Address**: `<public-ip>:25565`
5. Save configuration and join server


## Troubleshooting Guide

### Common Deployment Issues

#### AWS Authentication Failures
```bash
# Verify credentials
aws sts get-caller-identity

# Check configuration
aws configure list

# Test basic access
aws ec2 describe-regions
```

#### Terraform Execution Problems
```bash
# Clean and reinitialize
rm -rf .terraform
terraform init

# Validate configuration
terraform validate

# Plan with detailed output
terraform plan -detailed-exitcode

# If something wrong  in exucation you can destory
terraform destroy
```



#### Ansible Connection Issues
```bash
# Test SSH connectivity
ssh -i terraform/minecraft-deployment-key.pem ec2-user@<ip> -o ConnectTimeout=10

# Debug Ansible connection
ansible all -i inventory.ini -m ping -vvv

# Check security group rules
aws ec2 describe-security-groups --group-ids <sg-id>
```

#### Server Runtime Problems
```bash
# Connect to server
ssh -i terraform/minecraft-deployment-key.pem ec2-user@<ip>

# Check Java installation
java -version

# Verify Minecraft files
ls -la /home/ec2-user/minecraft-server/

# Review service logs
sudo journalctl -u minecraft --no-pager -l
```

## Resource Cleanup

To avoid ongoing AWS charges:
```bash
# Destroy all created resources
cd terraform
terraform destroy -auto-approve

# Verify cleanup completion
aws ec2 describe-instances --query 'Reservations[].Instances[?State.Name!=`terminated`]'
```




### Memory Configuration
Adjust JVM heap size based on instance type:
```bash
# For t3.large (8GB RAM)
ExecStart=/usr/bin/java -Xmx4096M -Xms2048M -jar server.jar nogui

# For t3.xlarge (16GB RAM)
ExecStart=/usr/bin/java -Xmx8192M -Xms4096M -jar server.jar nogui
```

## Development and Testing

This project was developed and tested using:
- **Operating System**: Amazon Linux 2023
- **Terraform Version**: 1.5.0
- **Ansible Core Version**: 2.17.0
- **AWS CLI Version**: 2.13.0
- **Java Runtime**: Amazon Corretto 21.0.1

## Resources and References

### Technical Documentation
- [AWS EC2 Instance Types](https://aws.amazon.com/ec2/instance-types/) - Instance sizing guidance
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest) - Infrastructure resource reference
- [Ansible YUM Module](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/yum_module.html) - Package management documentation
- [Amazon Corretto Documentation](https://docs.aws.amazon.com/corretto/) - Java runtime information

### Configuration References
- [systemd Service Files](https://www.freedesktop.org/software/systemd/man/systemd.service.html) - Service configuration format
- [Minecraft Server Properties](https://minecraft.fandom.com/wiki/Server.properties) - Game server configuration
- [AWS VPC User Guide](https://docs.aws.amazon.com/vpc/latest/userguide/) - Networking best practices

### Learning Materials
- [Infrastructure as Code Concepts](https://www.terraform.io/intro/index.html) - IaC principles and benefits
- [Ansible Best Practices](https://docs.ansible.com/ansible/latest/user_guide/playbooks_best_practices.html) - Configuration management guidelines
- [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/) - Cloud architecture 

### If you face dnf or yum error you can check here 
-[Stackoverflow] https://stackoverflow.com/questions/78702251/why-is-asking-for-dnf-when-yum-is-specified
-[Ansible] https://github.com/ansible/ansible/blob/stable-2.17/changelogs/CHANGELOG-v2.17.rst#removed-features-previously-deprecated

