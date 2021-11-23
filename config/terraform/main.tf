resource "aws_instance" "test_instance" {
  ami           = "ami-0a01a5636f3c4f21c"
  instance_type = "t2.micro"
  tags = {
    Name            = "HelloWorld"
    ITOwnerEmail    = "jeyabalaji_subramanian@cargill.com"
    ApplicationName = "test-instance"
    Environment     = "dev"
    Terraform       = "true"
  }
}