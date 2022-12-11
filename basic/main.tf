provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "tf-node" {
  ami = "ami-02b972fec07f1e659"
  subnet_id = "subnet-050368776de3ba445"
  instance_type = "t3.micro"
  tags = {
    Name = "my-tf-node"
  }
}
