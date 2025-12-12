# Scenario: DRIFT_CONFIG - Code changes not yet applied
# This demonstrates planned changes that haven't been applied to infrastructure

# Modified version of the web instance with different configuration
resource "aws_instance" "web_modified" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t3.medium"  # Changed from t3.small
  subnet_id     = aws_subnet.public.id

  vpc_security_group_ids = [aws_security_group.web.id]

  root_block_device {
    volume_size = 30  # Changed from 20
    volume_type = "gp3"
    iops        = 3000  # Added IOPS configuration
  }

  monitoring = true  # Added monitoring

  tags = {
    Name        = "terrasync-web-server"
    Environment = "production"  # Changed from development
    Application = "web"
    Version     = "v2"  # Added version tag
  }
}

# Modified S3 bucket with encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "data" {
  bucket = aws_s3_bucket.data.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
