# Experiment 01 — Create a Single IAM User Using Terraform

## Objective

Learn how to create, inspect, manage and destroy a single AWS IAM user using Terraform.

## Scenario

A developer is joining an organization. An IAM identity must be provisioned, but permissions and credentials will be managed separately.

## IAM Concepts

- IAM user
- Identity vs credentials
- Authentication vs authorization
- IAM ARN
- IAM user path
- IAM unique ID
- Default-deny authorization
- Terraform resource lifecycle

## Requirements

- Create IAM user `developer-alice`
- Assign IAM path `/developers/`
- Apply descriptive tags
- No console password
- No access keys
- No managed policies
- No inline policies
- No group memberships

## Terraform Resources

- `aws_iam_user`

## Implementation

The user is provisioned using Terraform with configurable username, path, environment and project metadata.

## Validation

- [x] Terraform configuration validates
- [x] Terraform plan shows one resource to create
- [x] IAM user exists in AWS
- [x] Username and path are correct
- [x] ARN and unique ID are retrieved
- [x] No managed policies are attached
- [x] No inline policies exist
- [x] No IAM groups are associated
- [x] No access keys exist
- [x] No console login profile exists
- [x] Tags are correct

## Key Learnings

1. Creating an identity does not automatically grant permissions.
2. Authentication and authorization are different concepts.
3. IAM users and their credentials are separate.
4. IAM paths are organizational identifiers, not permission boundaries.
5. Terraform manages resources through declared desired state.
6. AWS-side validation is necessary in addition to Terraform state inspection.

## Cleanup

Run `terraform destroy` and verify that the IAM user no longer exists.

## Definition of Done

The IAM user can be provisioned, inspected, validated, explained and destroyed entirely through Terraform and AWS CLI.
