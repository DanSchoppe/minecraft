resource "aws_instance" "minecraft" {
  instance_type = "c6i.large"
  # Ubuntu Server 20.04 LTS (HVM), SSD Volume Type
  ami = "ami-068663a3c619dd892"
  key_name = "minecraft"
  security_groups = [ aws_security_group.minecraft.name ]
  disable_api_termination = true

  tags = {
    Name = "Minecraft"
  }
}

resource "aws_security_group" "minecraft" {
  name = "minecraft"

  # Outbound internet access
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # # Minecraft Java
  # ingress {
  #   from_port = 25565
  #   to_port = 25565
  #   protocol = "tcp"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }

  # Minecraft Bedrock IPv4, IPv6
  ingress {
    from_port = 19132
    to_port = 19133
    protocol = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # SSH
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Ping
  ingress {
    from_port = 8
    to_port = 0
    protocol = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
