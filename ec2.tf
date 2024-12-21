module "ec2_instance" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name = "pixelation-ec2"

  ami                    = data.aws_ami.AmaLinux.id
  instance_type          = "t2.micro"
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name
  key_name               = "user1"
  monitoring             = true
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]
  subnet_id              = module.vpc.public_subnets.0
  user_data              = base64encode(file("userData.sh"))
}