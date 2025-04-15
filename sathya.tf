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
resource "aws_instance" "my_ec2_instance" {
  ami           = "ami-0ed194d7eff6d2f81"  # Replace with a valid AMI ID for your region
  instance_type = "t2.micro"  # Choose the instance type (e.g., t2.micro)

  tags = {
    Name = "MyEC2Instance"
  }
}

output "instance_id" {
  value = aws_instance.my_ec2_instance.id
}

output "public_ip" {
  value = aws_instance.my_ec2_instance.public_ip
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
