# Terraform Deployment Guide for eng4todaycore

## Prerequisites

To use the GitHub Actions workflows (or run Terraform effectively), you **must** configure a Remote Backend (S3) to store the infrastructure state. GitHub Actions runners are ephemeral and cannot use local state.

### 1. Create S3 Bucket and DynamoDB Table (One-time Setup)

You need to create these resources manually (or via AWS CLI) *before* running Terraform.

**AWS CLI Commands:**

```bash
# 1. Create S3 Bucket for State
aws s3api create-bucket --bucket eng4today-terraform-state --region us-east-1

# 2. Enable Versioning (Recommended)
aws s3api put-bucket-versioning --bucket eng4today-terraform-state --versioning-configuration Status=Enabled

# 3. Create DynamoDB Table for State Locking
aws dynamodb create-table \
    --table-name eng4today-terraform-locks \
    --attribute-definitions AttributeName=LockID,AttributeType=S \
    --key-schema AttributeName=LockID,KeyType=HASH \
    --provisioned-throughput ReadCapacityUnits=1,WriteCapacityUnits=1 \
    --region us-east-1
```

*Note: If you want to use a different bucket name, update `terraform/backend.tf` accordingly.*

### 2. Configure GitHub Secrets

Go to your GitHub Repository -> Settings -> Secrets and Variables -> Actions -> New Repository Secret.

Add the following secrets:

*   `AWS_ACCESS_KEY_ID`
*   `AWS_SECRET_ACCESS_KEY`
*   `DB_PASSWORD`: The password for your RDS PostgreSQL database.

## Deployment Steps

Because ECS Fargate requires a Docker image to exist before it can start, the first deployment is a 2-step process.

### Step 1: Create ECR Repository Only

1.  Run Terraform locally (or via a targeted plan) to create just the ECR repo:
    ```bash
    cd terraform
    terraform init
    terraform apply -target=aws_ecr_repository.main
    ```
2.  Get the ECR URL from the output.

### Step 2: Build and Push Docker Image

Build your Docker image and push it to the new ECR repository (tag it as `latest`).

```bash
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <YOUR_ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com
docker build -t eng4todaycore .
docker tag eng4todaycore:latest <ECR_URL>:latest
docker push <ECR_URL>:latest
```

### Step 3: Full Deployment

Now you can run the full Terraform apply (locally or via GitHub Actions by pushing to `main`).

```bash
terraform apply
```

## Destroying Resources

To destroy resources, run the "Terraform Destroy (Manual)" workflow in GitHub Actions (Actions tab -> Select Workflow -> Run workflow -> Type "DESTROY").
