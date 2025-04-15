#Create S3 Bucket
provider "aws" {
  region = "ap-south-1"
}

resource "aws_s3_bucket" "my_bucket" {
  bucket = "mybucpriya27"
  acl    = "private"  # Set the access control list (ACL)

  tags = {
    Name        = "My S3 Bucket"
    Environment = "Dev"
  }
}


resource "aws_s3_bucket" "exam_bucket" {
  bucket = "nadir22" 
  acl    = "private"
}

output "bucket_name" {
  value = aws_s3_bucket.exam_bucket.bucket
}


#Create IAM User
resource "aws_iam_user" "sathya" {
  name = "sathya"  # Set the desired user name
}

resource "aws_iam_user_policy_attachment" "admin_user_policy" {
  user       = aws_iam_user.sathya.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

output "iam_user_name" {
  value = aws_iam_user.sathya
}

#Create EC2 Instances
resource "aws_instance" "my_ec2" {
  ami                         = "ami-0d682f26195e9ec0f"
  instance_type               = "t2.small"
  subnet_id                   = aws_subnet.public-sub.id  # Reference subnet from vpc.tf
  security_groups             = [aws_security_group.allow_tls.id]  # Reference SG from vpc.tf
  associate_public_ip_address = true
  key_name                    = "vpcpracticals-29"

  tags = {
    Name = "my-ec2-instance"
  }
}


# Create an SNS Topic
resource "aws_sns_topic" "sp_sns_topic" {
  name = "sp-sns-topic"
}

# Create an SNS Subscription (e.g., Email)
resource "aws_sns_topic_subscription" "my_email_subscription" {
  topic_arn = aws_sns_topic.sp_sns_topic.arn
  protocol  = "email"  # Change this to 'sms', 'lambda', etc. for other protocols
  endpoint  = "sathyapriyasuresh27@gmail.com"  # Replace with the recipient email address
}

output "sns_topic_arn" {
  value = aws_sns_topic.sp_sns_topic.arn
}
