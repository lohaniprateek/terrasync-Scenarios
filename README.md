# TerraSync Test Fixtures

This directory contains Terraform configurations for testing TerraSync features.

## Test Scenarios

### Scenario 1: Basic Resource Creation
**Purpose**: Test basic code parsing and state loading
**Files**: `main.tf`, `variables.tf`, `outputs.tf`

Resources created:
- VPC with DNS enabled
- Public subnet
- Security group with HTTP/HTTPS ingress
- EC2 instance (t3.small)
- S3 bucket with versioning

### Scenario 2: Configuration Drift (DRIFT_CONFIG)
**Purpose**: Test detection of code changes not yet applied

**Steps to simulate**:
1. Apply the initial configuration
2. Modify `instance_type` in variables.tf from `t3.small` to `t3.medium`
3. Run `terrasync resolve`

**Expected**: TerraSync should show `DRIFT_CONFIG` for aws_instance.web

### Scenario 3: External Drift (DRIFT_EXTERNAL)
**Purpose**: Test detection of manual changes made outside Terraform

**Steps to simulate**:
1. Apply the initial configuration
2. Manually modify the security group in AWS Console (add a new ingress rule)
3. Run `terrasync resolve`

**Expected**: TerraSync should show `DRIFT_EXTERNAL` for aws_security_group.web

### Scenario 4: State Drift (DRIFT_STATE)
**Purpose**: Test state vs deployed differences

**Steps to simulate**:
1. Apply the initial configuration
2. Manually modify terraform.tfstate file (change instance type)
3. Run `terrasync resolve`

**Expected**: TerraSync should show `DRIFT_STATE`

### Scenario 5: Three-Way Conflict (CONFLICT)
**Purpose**: Test complex scenario where all three sources differ

**Steps to simulate**:
1. Apply initial configuration
2. Change instance_type in code to `t3.large`
3. Manually change instance type in AWS to `t3.xlarge`
4. State still shows `t3.small`
5. Run `terrasync resolve`

**Expected**: TerraSync should show `CONFLICT` with all three versions displayed

## Using with LocalStack

For local testing without AWS credentials:

```bash
# Start LocalStack
docker run -d -p 4566:4566 localstack/localstack

# Configure endpoints in main.tf provider block (uncomment the endpoints section)

# Run terraform
terraform init
terraform apply
```

## Testing TerraSync Commands

### Test Code Loader
```bash
cd /home/prateek/workDir/terrasync
go run main.go resolve --output test-output.json
```

This should parse the .tf files in test-fixtures/ and display resources.

### Test State Loader
```bash
# First initialize and apply
cd test-fixtures
terraform init
terraform apply -auto-approve

# Then run TerraSync
cd ..
go run main.go resolve
```

### Test Deployed Loader
```bash
# After resources are created, modify something manually
# Then run TerraSync to detect drift
go run main.go resolve
```

## Resource Count

This fixture creates:
- 1 VPC
- 1 Subnet
- 1 Security Group (with 3 rules)
- 1 EC2 Instance
- 1 S3 Bucket
- 1 S3 Bucket Versioning config
- 1 S3 Public Access Block

**Total**: 7 distinct resources to track

## Notes

- The provider is configured with `skip_credentials_validation = true` for testing purposes
- For real AWS testing, remove the skip flags and ensure AWS credentials are configured
- The AMI ID is a placeholder and may need to be updated for your region
- S3 bucket names must be globally unique - update `bucket_name` variable
