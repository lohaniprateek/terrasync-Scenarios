# Module-based configuration test
# Tests TerraSync with Terraform modules

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  # version = "~> 5.0"  # Uncomment for real testing

  name = "terrasync-module-vpc"
  cidr = "10.1.0.0/16"

  azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24"]
  public_subnets  = ["10.1.101.0/24", "10.1.102.0/24", "10.1.103.0/24"]

  enable_nat_gateway = true
  enable_vpn_gateway = false

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Terraform   = "true"
    Environment = "dev"
    ManagedBy   = "terrasync-test"
  }
}

module "ec2_cluster" {
  source = "terraform-aws-modules/ec2-instance/aws"
  # version = "~> 5.0"  # Uncomment for real testing

  name = "terrasync-cluster"

  instance_type          = "t3.small"
  ami                    = "ami-0c55b159cbfafe1f0"
  vpc_security_group_ids = [aws_security_group.web.id]
  subnet_id              = module.vpc.public_subnets[0]

  tags = {
    Environment = "dev"
    Application = "web-cluster"
  }
}

# This demonstrates how TerraSync should handle module resources
# Module resources will have addresses like:
# - module.vpc.aws_vpc.this[0]
# - module.ec2_cluster.aws_instance.this[0]
