provider "aws" {
  region = "us-east-1"
}

resource "aws_key_pair" "deployer" {
  key_name   = "minecraft-key"
  public_key = file("~/.ssh/minecraft-key.pub")
}

resource "aws_security_group" "mc_sg" {
  name        = "minecraft-sg"
  description = "Security group for Minecraft server with SSH access"

  # Allow Minecraft traffic
  ingress {
    description = "Allow Minecraft port"
    from_port   = 25565
    to_port     = 25565
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # ✅ Allow SSH traffic
  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "mc_server" {
  ami                         = "ami-0c02fb55956c7d316"  # Amazon Linux 2
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.deployer.key_name
  vpc_security_group_ids      = [aws_security_group.mc_sg.id]
  associate_public_ip_address = true

  tags = {
    Name = "MinecraftServer"
  }
}
