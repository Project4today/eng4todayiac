# Eng4Today Infrastructure

This repository contains the Infrastructure as Code (IaC) and configuration for the Eng4Today project.

## Project Structure

- **terraform/**: Contains Terraform configuration files to provision AWS resources (VPC, ECS, ECR, IAM, etc.).

## Deployment

Detailed deployment instructions, including the initial ECR setup and Docker build steps, can be found in the [Terraform README](terraform/README.md).

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) >= 1.0.0
- [AWS CLI](https://aws.amazon.com/cli/)