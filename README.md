# AWS IAM Mastery Lab

A progressive, hands-on AWS Identity and Access Management (IAM)
laboratory built with Terraform.

The goal of this repository is to understand how AWS identities are
created, how permissions are granted and evaluated, how access is
controlled, and how AWS resources authorize those identities. Each
concept is explored through a practical, independently executable
Terraform experiment.

> **Learning-lab boundary:** The production architecture described in
> the AWS architecture blueprint is intended to use IAM Identity Center,
> temporary credentials, and IAM roles for human access. The IAM-user
> experiments in this repository are learning exercises---not the
> recommended final production access model.

## Learning approach

Rather than studying IAM resources in isolation, this lab progresses
from simple identity creation to enterprise access governance:

1.  Create an IAM user and inspect its identity.
2.  Assign permissions using IAM policies.
3.  Centralize permissions with IAM groups.
4.  Introduce roles, temporary credentials, and role assumption.
5.  Control access through resource-based policies.
6.  Explore advanced authorization and guardrails.
7.  Apply enterprise identity patterns, including IAM Identity Center
    and GitHub OIDC.

Every experiment follows the same engineering workflow:

1.  Understand the IAM concept.
2.  Define a real-world use case.
3.  Specify the expected access-control behavior.
4.  Implement the configuration using Terraform.
5.  Deploy the configuration.
6.  Test allowed operations.
7.  Test denied operations.
8.  Inspect the resulting IAM configuration.
9.  Destroy the experiment and document findings.

**An experiment is incomplete without a negative authorization test.**
Testing only what a principal can do does not demonstrate that access is
properly restricted.

## Learning objectives

By completing the lab, you will develop practical understanding of:

-   IAM users, groups, roles, credentials, authentication, and identity
    lifecycle.
-   Managed policies, inline policies, policy evaluation, and least
    privilege.
-   Trust policies, principals, conditions, STS, and role assumption.
-   Identity-based and resource-based authorization.
-   S3 bucket policies and KMS key policies.
-   Explicit denies, permissions boundaries, ABAC, and session policies.
-   IAM troubleshooting using the policy simulator, AWS CLI, and
    CloudTrail.
-   IAM Identity Center, cross-account access, GitHub OIDC federation,
    and Service Control Policies (SCPs).

## Experiment roadmap

The lab contains **29 experiments across seven phases**, numbered `00`
through `28`.

### Phase I --- IAM users and identity fundamentals

**Goal:** Understand what an IAM user represents, how it authenticates,
and how AWS identifies it.

| ID | Experiment | Scenario / focus |
| --- | --- | --- |
| 00 | Establish the IAM lab environment | Configure the provider, identify the account and caller, establish a Terraform execution identity, configure state, and define common tags. |
| 01 | Create a single IAM user | Create `developer-alice`; inspect tags, path, ARN, and unique ID; verify that identity creation grants no permissions. |
| 02 | Create programmatic credentials | Learn access key ID and secret access key, configure an AWS CLI profile, and authenticate as the user. |
| 03 | Understand default-deny behavior | Attempt S3 listing and upload without permissions; observe authorization failures. |

### Phase II --- IAM policies and permission assignment

**Goal:** Understand how permissions are expressed and attached to
identities.

| ID | Experiment | Scenario / focus |
| --- | --- | --- |
| 04 | Create a custom IAM policy | Allow Alice to list S3 buckets with `s3:ListAllMyBuckets`; study policy elements and attachment. |
| 05 | Restrict access to a specific S3 bucket | Grant bucket-level listing and object-level read/write access to `development-data`, not another bucket. |
| 06 | Explore AWS managed policies | Compare `AmazonS3ReadOnlyAccess` with a custom policy, then detach it and restore the custom policy. |
| 07 | Create an inline IAM policy | Attach a user-specific inline policy and compare its lifecycle and reusability with a managed policy. |
| 08 | Understand multiple policy evaluation | Combine S3 read and write allows with an explicit delete deny; test explicit allow, implicit deny, and explicit deny. |

### Phase III --- IAM groups and scalable permission management

**Goal:** Move from managing individual users to managing permissions at
team level.

| ID | Experiment | Scenario / focus |
| --- | --- | --- |
| 09 | Create an IAM group | Add five developers to a `developers` group and attach a shared S3 read policy. |
| 10 | Create multiple teams with different permissions | Create `developers`, `analysts`, and `administrators` groups with different permission scopes; verify separation. |
| 11 | User onboarding and offboarding | Add a user to a team, move them between groups, remove membership, and deactivate or delete the identity as appropriate. |

### Phase IV --- IAM roles and temporary credentials

**Goal:** Understand why roles exist and how they differ from IAM users.

| ID | Experiment | Scenario / focus |
| --- | --- | --- |
| 12 | Create an IAM role | Create an EC2-assumable role with S3 read permissions. |
| 13 | Understand the trust policy | Configure EC2 as the trusted service principal; study `Principal` and `sts:AssumeRole`. |
| 14 | Attach an IAM role to EC2 | Use an instance profile so EC2 can access S3 without storing long-lived credentials on the instance. |
| 15 | Assume a role using STS | Allow Alice to assume a deployment role and use temporary credentials to access a resource. |

### Phase V --- Resource-based policies and resource access

**Goal:** Understand authorization through policies attached to
resources as well as identities.

| ID | Experiment | Scenario / focus |
| --- | --- | --- |
| 16 | Create an S3 bucket policy | Compare access for Alice and another user using identity-based and bucket policies. |
| 17 | Grant cross-account S3 access | Allow a role in Account B to read objects in a bucket owned by Account A. |
| 18 | Understand KMS key policies | Configure KMS key and IAM policies so an identity can read and decrypt an SSE-KMS-encrypted S3 object. |
| 19 | Introduce explicit resource-level restrictions | Deny S3 requests that do not use secure transport with `aws:SecureTransport`. |

### Phase VI --- Advanced IAM authorization

**Goal:** Govern permissions when multiple teams, environments, and
policies interact.

| ID | Experiment | Scenario / focus |
| --- | --- | --- |
| 20 | IAM permissions boundary | Set a maximum-permission boundary for a developer who can create IAM policies and roles. |
| 21 | Attribute-Based Access Control (ABAC) | Use `aws:PrincipalTag` and `aws:ResourceTag` to scope project access by tags. |
| 22 | IAM policy conditions | Experiment with `aws:RequestedRegion`, `aws:SourceIp`, `aws:MultiFactorAuthPresent`, principal/resource tags, and secure transport. |
| 23 | Session policies | Restrict an assumed role session beyond the permissions granted to the role. |
| 24 | Policy simulator and access troubleshooting | Investigate identity policies, resource policies, boundaries, session policies, explicit denies, organization policies, and CloudTrail events. |

### Phase VII --- Enterprise IAM and organizational access

**Goal:** Transition from individual IAM identities to the
production-style identity architecture in the AWS blueprint.

| ID | Experiment | Scenario / focus |
| --- | --- | --- |
| 25 | IAM Identity Center | Create users, groups, permission sets, and account assignments; authenticate through the portal and inspect temporary credentials. |
| 26 | Cross-account role access | Configure platform roles across development, staging, and production accounts; test permitted and prohibited transitions. |
| 27 | CI/CD execution role | Configure GitHub OIDC federation and a repository/branch-scoped deployment role; verify other repositories or branches cannot assume it. |
| 28 | Service Control Policies (SCPs) | Use an AWS Organization and OU to apply organization-level restrictions and compare SCPs with IAM policies. |

## Repository structure

Keep all experiments in one repository. Each experiment should be
independently executable and documented.

``` text
aws-iam-mastery-lab/
│
├── README.md
│
├── docs/
│   ├── concepts/
│   │   ├── authentication.md
│   │   ├── authorization.md
│   │   ├── policy-evaluation.md
│   │   ├── trust-policy.md
│   │   └── iam-vs-roles.md
│   │
│   └── architecture/
│
├── experiments/
│   ├── 00-iam-lab-setup/
│   ├── 01-single-iam-user/
│   ├── 02-programmatic-credentials/
│   ├── 03-default-deny/
│   ├── 04-custom-iam-policy/
│   ├── 05-resource-restricted-access/
│   ├── 06-managed-policies/
│   ├── 07-inline-policies/
│   ├── 08-policy-evaluation/
│   ├── 09-iam-groups/
│   ├── 10-team-based-access/
│   ├── 11-user-lifecycle/
│   ├── 12-iam-roles/
│   ├── 13-trust-policies/
│   ├── 14-ec2-instance-roles/
│   ├── 15-sts-assume-role/
│   ├── 16-s3-bucket-policies/
│   ├── 17-cross-account-s3/
│   ├── 18-kms-key-policies/
│   ├── 19-resource-restrictions/
│   ├── 20-permissions-boundaries/
│   ├── 21-abac/
│   ├── 22-policy-conditions/
│   ├── 23-session-policies/
│   ├── 24-policy-troubleshooting/
│   ├── 25-identity-center/
│   ├── 26-cross-account-roles/
│   ├── 27-github-oidc/
│   └── 28-service-control-policies/
│
└── .github/
    └── workflows/
```

A typical experiment directory contains:

``` text
01-single-iam-user/
├── main.tf
├── variables.tf
├── outputs.tf
├── providers.tf
├── README.md
└── tests/
    └── validation.md
```

Use isolated Terraform state for experiments, especially those that
create or modify identities and organizational controls. This helps
prevent one experiment from accidentally destroying resources belonging
to another.

## Experiment documentation template

Use a consistent structure for every experiment.

| Section | What to document |
| --- | --- |
| Objective | What concept are we learning? |
| Scenario | What real-world problem are we solving? |
| Prerequisites | What must already exist? |
| IAM concepts | Which IAM concepts are involved? |
| Architecture | Which identities and resources interact? |
| Terraform implementation | Which resources are provisioned? |
| Positive tests | Which operations should succeed? |
| Negative tests | Which operations should fail? |
| Observations | What did we learn? |
| Cleanup | What needs to be destroyed? |

For example, in Experiment 05, the tests should demonstrate that:

-   Alice can list `development-data`.
-   Alice can read objects from `development-data`.
-   Alice cannot read `production-data`.
-   Alice cannot delete objects if delete permission was not granted.

## Lab safety rules

IAM experiments can affect account access. Follow these rules throughout
the lab:

-   Never use the AWS root account for Terraform execution.
-   Use a dedicated sandbox AWS account.
-   Never grant unrestricted IAM administration to experimental users.
-   Never commit access keys or Terraform state files.
-   Do not put access key secrets in Terraform code, outputs, or
    committed `.tfvars` files. Terraform-managed access keys can expose
    sensitive values through state. Use a controlled
    credential-generation and storage process.
-   Establish a break-glass administrative identity before experimenting
    with restrictive policies.
-   Be especially careful with SCPs and permissions boundaries; they can
    prevent otherwise authorized operations.
-   Inspect Terraform plans before applying or destroying resources,
    particularly when shared resources are involved.
-   Destroy experimental resources when finished.

## Starting point

Work through the experiments sequentially rather than implementing the
entire roadmap at once.

**Start with Experiment 01 --- Create a single IAM user using
Terraform.**

Deliverables:

-   Understand IAM user, ARN, path, and unique ID.
-   Understand authentication versus authorization.
-   Write the Terraform configuration.
-   Deploy the user.
-   Inspect it through the AWS CLI.
-   Verify that it has no permissions.
-   Destroy the user through Terraform.

**Definition of done:** You can create, inspect, explain, and destroy an
IAM user without using the AWS Console.

Experiment 00 establishes the lab environment and should be completed
first if it has not already been completed.

------------------------------------------------------------------------

This repository is an IAM engineering lab: 29 progressively difficult
experiments designed to build understanding of both Terraform
implementation and the reasoning behind enterprise AWS identity and
access architecture.
