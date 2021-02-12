provider "aws" {  
  region = "eu-central-1"
}

resource "aws_iam_role_policy" "ubuntu_policy" {
  name = "ubuntu_policy"
  role = aws_iam_role.ubuntu_role.id
  policy = templatefile ("role.policy.json.tpl", {
    res_buck = aws_s3_bucket.vsanextbucket.bucket,
    res_sqs = aws_sqs_queue.terraform_queue.name
  })
}

resource "aws_iam_role" "ubuntu_role" {
  name = "ubuntu_role"
  assume_role_policy = file ("role.json")
}

resource "aws_iam_instance_profile" "ubuntu_profile" {
  name = "ubuntu_profile"
  role = aws_iam_role.ubuntu_role.id
}

resource "aws_key_pair" "terra" {
  key_name   = "terra"
  public_key = file("/home/aqvila/.ssh/terra.pub")
}

resource "aws_instance" "my_ubuntu" {
  ami = "ami-0932440befd74cdba"
  instance_type = "t2.micro"
  key_name = aws_key_pair.terra.key_name
  iam_instance_profile = aws_iam_instance_profile.ubuntu_profile.id
  tags = {
    "Name" = "ubuntu-terraform"
    "Owner"="Vdovenko"
  }
}

resource "aws_s3_bucket" "vsanextbucket" {
  bucket = "vsa.nextbucket"
  acl    = "private"
  tags = {
    Name        = "My bucket"
  }
}
resource "aws_sqs_queue" "terraform_queue" {
  name                      = "terraform-example-queue"
  receive_wait_time_seconds = 20
}