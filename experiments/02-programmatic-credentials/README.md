# Experiment 02 — IAM User Programmatic Credentials

## Objective

Learn how an IAM user authenticates programmatically with AWS using an access key ID and secret access key.

Configure an AWS CLI named profile, verify authentication using AWS STS, and understand why valid credentials do not automatically grant permissions.

## Scenario

Building on Experiment 01, we already have an IAM user:

| Attribute | Value |
|---|---|
| Username | developer-alice |
| IAM Path | /developers/ |
| Identity | Existing IAM user |
| Credentials | Programmatic access key |
| Permissions | None explicitly assigned |

Alice now needs to interact with AWS through the CLI.

We will create an access key for her without granting additional permissions.

## IAM Concepts

- AWS access keys
- Access Key ID vs Secret Access Key
- IAM user authentication
- Authentication vs authorization
- AWS CLI named profiles
- AWS Signature Version 4 (SigV4)
- Terraform sensitive outputs
- Terraform state security
- Access key lifecycle and revocation
- Long-lived credentials vs temporary credentials

## Prerequisites

- Experiment 01 completed.
- Existing IAM user `developer-alice`.
- Terraform installed.
- AWS CLI installed and configured.
- AWS administrative execution identity with IAM access key management permissions.

## Terraform Implementation

### Resources

| Resource | Purpose |
|---|---|
| `aws_iam_access_key` | Creates an access key for an existing IAM user |

### Configuration

The Terraform configuration creates an access key for `developer-alice`.

```hcl
resource "aws_iam_access_key" "developer" {
  user = var.iam_user_name
}
```

### Outputs

| Output | Description | Sensitive |
|---|---|---|
| access_key_id | Access key identifier | No |
| secret_access_key | Secret access key | Yes |

**Security consideration:** Terraform's `sensitive = true` masks the secret in normal output, but the secret remains stored in Terraform state.

Never commit Terraform state files or expose credentials in screenshots.

## Implementation Workflow

### 1. Verify the administrator identity

```bash
aws sts get-caller-identity
```

### 2. Verify the existing IAM user

```bash
aws iam get-user \
  --user-name developer-alice
```

### 3. Create the access key

```bash
tofu init
tofu fmt -recursive
tofu validate
tofu plan
tofu apply
```

### 4. Retrieve the outputs

```bash
tofu output -raw access_key_id
```

Retrieve the secret only when needed:

```bash
tofu output -raw secret_access_key
```

Never include the secret in terminal screenshots or Git-tracked files.

### 5. Configure the AWS CLI profile

```bash
aws configure --profile developer-alice
```

Configure the access key ID, secret access key, region, and output format.

The profile is stored locally in:

- `~/.aws/credentials`
- `~/.aws/config`

### 6. Verify authentication

```bash
aws sts get-caller-identity \
  --profile developer-alice
```

Expected result: AWS recognizes `developer-alice` as the caller.

## Testing and Verification

### Authentication Tests

| Test | Expected Result |
|---|---|
| STS GetCallerIdentity | Successful |
| Caller ARN | developer-alice |
| AWS Account | Expected sandbox account |

### Authorization Tests

Execute the following commands using Alice's profile.

**Test 01 — List S3 buckets**

```bash
aws s3api list-buckets \
  --profile developer-alice
```

Expected: `AccessDenied`

**Test 02 — List IAM users**

```bash
aws iam list-users \
  --profile developer-alice
```

Expected: `AccessDenied`

These operations demonstrate that successful authentication does not automatically grant AWS service permissions.

Note: `sts:GetCallerIdentity` is a special operation that does not require an explicit Allow permission.

### Administrator Verification

```bash
aws iam list-access-keys \
  --user-name developer-alice
```

Verify the access key status and metadata.

The secret access key is not returned by this API.

## Terraform Lifecycle

Inspect Terraform state:

```bash
terraform state list
```

Expected:

```text
aws_iam_access_key.developer
```

Destroy the access key:

```bash
terraform destroy
```

Verify that the credentials no longer work:

```bash
aws sts get-caller-identity \
  --profile developer-alice
```

Expected: Authentication failure.

The IAM user itself should remain intact.

Remove the obsolete local AWS CLI profile after verification.

## Test Results

Record actual execution results below.

| Test | Expected Result | Actual Result |
|---|---|---|
| Terraform validation | Success | Success |
| Access key creation | Success | Success |
| AWS CLI profile | Configured | Configured |
| STS authentication | Success | Success |
| S3 bucket listing | AccessDenied | AccessDenied |
| IAM user listing | AccessDenied | AccessDenied |
| Access key metadata | Active | Active |
| Terraform destroy | Success | Success |
| Authentication after deletion | Failure | Failure |

## Test Evidence

Screenshots are maintained in the `evidence/` directory.

| Evidence | Description |
|---|---|
| 01-access-key-created.png | Terraform access key creation |
| 02-aws-cli-profile.png | AWS CLI profile configuration with credentials redacted |
| 03-sts-identity.png | Successful identity verification |
| 04-s3-access-denied.png | S3 authorization failure |
| 05-iam-access-denied.png | IAM authorization failure |
| 06-access-key-destroyed.png | Terraform cleanup and credential revocation |

## Key Learnings

1. IAM users and access keys are separate resources.
2. An access key consists of an access key ID and a secret access key.
3. AWS CLI named profiles allow multiple AWS identities to be configured locally.
4. STS GetCallerIdentity verifies the authenticated caller.
5. Authentication does not imply authorization.
6. Terraform sensitive outputs do not remove secrets from state.
7. An access key's secret cannot be retrieved again through IAM APIs after creation.
8. Destroying an access key does not delete its associated IAM user.
9. Long-lived IAM user credentials should generally be avoided for human access in production.

## Production Perspective

For production environments, prefer:

| Use Case | Recommended Approach |
|---|---|
| Human developers | IAM Identity Center |
| EC2 applications | IAM instance roles |
| Lambda applications | Lambda execution roles |
| GitHub Actions | OIDC federation |
| Cross-account access | IAM roles and STS |

This experiment uses long-lived credentials strictly for learning purposes.

## Cleanup

- [ ] Destroy the Terraform-managed access key.
- [ ] Verify that the access key no longer authenticates.
- [ ] Remove the obsolete local AWS CLI profile.
- [ ] Confirm that the IAM user still exists.
- [ ] Ensure Terraform state and credentials are not committed.

## Definition of Done

The existing IAM user can authenticate programmatically through an AWS CLI named profile, while unauthorized service operations are denied.

The access key lifecycle has been inspected, documented, and safely completed.