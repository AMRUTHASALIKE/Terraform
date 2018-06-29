module "vpc" {
  source = "./modules"
}

resource "aws_internet_gateway" "igw1" {
  vpc_id = "${module.vpc.vpc_id}"
}

resource "aws_route" "internet_access" {
  route_table_id         = "${module.vpc.route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.igw1.id}"
}

resource "aws_subnet" "subnet1" {
  vpc_id                  = "${module.vpc.vpc_id}"
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
}

resource "aws_security_group" "sg1" {
  name        = "terraform_sg"
  description = "Used in the terraform"
  vpc_id      = "${module.vpc.vpc_id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP access from the VPC
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "terraform" {
  key_name = "terraform-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQChBD6AEbtU1h4Z6G1wQUMd3HUHrf0eI35lYrGAUVjZtCeE+Y59dN/tYdA89JPswf4JFgHpz4pu+uAnSsB9ByrW5vWZpT0BwoJfr9WFPMnf58vMMpeBrbN2fM5/p8ojCvQ/dlEzfORAObT3YgCGpxu1A3Dv2/oX3Ir04CQUm9sNzu3aLhIBYVhaa6Upak/Jw5DlvXpTx/YofsjpA+U5EARdEhT6ggVP0ODPQe3UgD4XNBJ2ztzcDunUM1YpXIJB244IX9icd0ts5JiInX/uuDDsVvLk80bEbrVviqGxgDRUA2dTpvDWiHf1DpB36vwJ7ckiRsOz/lMztWPLyJzLua5P amrutha@amrutha-VirtualBox"
}

resource "aws_instance" "instance1" {
  ami           = "ami-1960d164"
  instance_type = "t2.micro"
  vpc_security_group_ids = ["${aws_security_group.sg1.id}"]
  subnet_id = "${aws_subnet.subnet1.id}"
  key_name = "${aws_key_pair.terraform.id}"

 tags {
   Name = "terraform instance"
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir ~/d1",
    ]
    
    connection {
    private_key = "${file("~/.ssh/id_rsa")}"
    user = "ubuntu"
  }
  }
}


output "instance ip" {
    value = ["${aws_instance.instance1.*.public_ip}"]
}


