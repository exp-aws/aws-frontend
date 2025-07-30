# Deployment Guide

This guide explains how to set up the CI/CD pipeline to automatically deploy your React application to AWS ECR.

## Prerequisites

1. **AWS Account** with ECR repository created
2. **GitHub Repository** with your code
3. **AWS IAM User** with ECR permissions

## AWS ECR Repository

Your ECR repository should be created with the following Terraform configuration:

```hcl
resource "aws_ecr_repository" "frontend" {
  name                 = "frontend"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
}
```

## GitHub Secrets Setup

You need to add the following secrets to your GitHub repository:

1. Go to your GitHub repository
2. Navigate to **Settings** → **Secrets and variables** → **Actions**
3. Add the following secrets:

### Required Secrets

- `AWS_ACCESS_KEY_ID`: Your AWS access key ID
- `AWS_SECRET_ACCESS_KEY`: Your AWS secret access key

### Optional Environment Variables

You can also set these as repository variables:
- `AWS_REGION`: Your AWS region (default: us-east-1)
- `ECR_REPOSITORY`: Your ECR repository name (default: frontend)

## IAM Permissions

Your AWS IAM user needs the following permissions for ECR:

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ecr:GetAuthorizationToken",
                "ecr:BatchCheckLayerAvailability",
                "ecr:GetDownloadUrlForLayer",
                "ecr:BatchGetImage",
                "ecr:PutImage",
                "ecr:InitiateLayerUpload",
                "ecr:UploadLayerPart",
                "ecr:CompleteLayerUpload"
            ],
            "Resource": "*"
        }
    ]
}
```

## How It Works

1. **Trigger**: The pipeline runs when you push to the `main` branch or create a pull request
2. **Build**: Uses Docker Buildx with layer caching for faster builds
3. **Tag**: Creates two tags:
   - `latest`: Always points to the most recent build
   - `{commit-sha}`: Specific version for each commit
4. **Push**: Automatically pushes to your ECR repository

## Manual Deployment

If you need to deploy manually, you can run:

```bash
# Build the image
docker build -t frontend .

# Tag for ECR
docker tag frontend:latest {aws-account-id}.dkr.ecr.{region}.amazonaws.com/frontend:latest

# Login to ECR
aws ecr get-login-password --region {region} | docker login --username AWS --password-stdin {aws-account-id}.dkr.ecr.{region}.amazonaws.com

# Push to ECR
docker push {aws-account-id}.dkr.ecr.{region}.amazonaws.com/frontend:latest
```

## Troubleshooting

### Common Issues

1. **Authentication Error**: Make sure your AWS credentials are correct
2. **Permission Denied**: Verify your IAM user has ECR permissions
3. **Build Failures**: Check the Dockerfile and nginx.conf for syntax errors
4. **Region Mismatch**: Ensure the AWS_REGION matches your ECR repository

### Debugging

- Check GitHub Actions logs for detailed error messages
- Verify ECR repository exists and is accessible
- Test AWS credentials locally with AWS CLI

## Next Steps

After the image is pushed to ECR, you can:

1. Deploy to ECS/Fargate
2. Deploy to EKS
3. Deploy to EC2 with Docker
4. Use with AWS App Runner

The image URI will be: `{aws-account-id}.dkr.ecr.{region}.amazonaws.com/frontend:latest` 