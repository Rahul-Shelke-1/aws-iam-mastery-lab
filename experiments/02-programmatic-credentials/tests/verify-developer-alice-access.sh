#!/usr/bin/env bash
set -euo pipefail

USER_NAME="${1:-developer-alice}"
PROFILE_NAME="${2:-$USER_NAME}"
REGION="${AWS_DEFAULT_REGION:-us-east-1}"
ENDPOINT_ARGS=()

if [ -n "${AWS_ENDPOINT_URL:-}" ]; then
  ENDPOINT_ARGS=(--endpoint-url "$AWS_ENDPOINT_URL")
fi

FAILURES=0
CREATED_KEY_ID=""

pass() {
  echo "[PASS] $1"
}

fail() {
  echo "[FAIL] $1"
  FAILURES=$((FAILURES + 1))
}

# Helper for AWS CLI calls using the active (administrator) credentials
admin_aws() {
  aws "${ENDPOINT_ARGS[@]}" "$@"
}

# Helper for AWS CLI calls using the configured developer-alice profile
alice_aws() {
  aws --profile "$PROFILE_NAME" "${ENDPOINT_ARGS[@]}" "$@"
}

# Optional cleanup helper if you want to remove the test key and profile on exit:
# Set CLEANUP_ON_EXIT=true if you want automatic cleanup after testing.
cleanup() {
  if [ "${CLEANUP_ON_EXIT:-false}" = "true" ] && [ -n "$CREATED_KEY_ID" ]; then
    admin_aws iam delete-access-key --user-name "$USER_NAME" --access-key-id "$CREATED_KEY_ID" >/dev/null 2>&1 || true
    aws configure set aws_access_key_id "" --profile "$PROFILE_NAME" >/dev/null 2>&1 || true
    aws configure set aws_secret_access_key "" --profile "$PROFILE_NAME" >/dev/null 2>&1 || true
    aws configure set region "" --profile "$PROFILE_NAME" >/dev/null 2>&1 || true
  fi
}
trap cleanup EXIT

echo "Verifying IAM user access flow for '$USER_NAME' (profile: '$PROFILE_NAME')"
echo "------------------------------------------------------------------------"

# 1. Verify the administrator identity
ADMIN_IDENTITY=$(admin_aws sts get-caller-identity --output json 2>/dev/null || true)
if [ -n "$ADMIN_IDENTITY" ]; then
  ADMIN_ARN=$(echo "$ADMIN_IDENTITY" | jq -r '.Arn // empty')
  ADMIN_ACCOUNT=$(echo "$ADMIN_IDENTITY" | jq -r '.Account // empty')
  pass "Administrator identity verified (Account: $ADMIN_ACCOUNT, ARN: $ADMIN_ARN)"
else
  fail "Failed to verify administrator identity via sts get-caller-identity"
  echo "RESULT: $FAILURES CHECK(S) FAILED"
  exit 1
fi

# 2. Create the access key
KEY_JSON=$(admin_aws iam create-access-key --user-name "$USER_NAME" --output json 2>/dev/null || true)
CREATED_KEY_ID=$(echo "$KEY_JSON" | jq -r '.AccessKey.AccessKeyId // empty')
CREATED_SECRET_KEY=$(echo "$KEY_JSON" | jq -r '.AccessKey.SecretAccessKey // empty')

if [ -n "$CREATED_KEY_ID" ] && [ -n "$CREATED_SECRET_KEY" ]; then
  pass "Created access key '$CREATED_KEY_ID' for '$USER_NAME'"
else
  fail "Failed to create access key for '$USER_NAME'"
  echo "RESULT: $FAILURES CHECK(S) FAILED"
  exit 1
fi

# 3. Configure the developer-alice AWS CLI profile
aws configure set aws_access_key_id "$CREATED_KEY_ID" --profile "$PROFILE_NAME"
aws configure set aws_secret_access_key "$CREATED_SECRET_KEY" --profile "$PROFILE_NAME"
aws configure set region "$REGION" --profile "$PROFILE_NAME"
if [ -n "${AWS_ENDPOINT_URL:-}" ]; then
  aws configure set endpoint_url "$AWS_ENDPOINT_URL" --profile "$PROFILE_NAME"
fi
pass "Configured AWS CLI profile '$PROFILE_NAME'"

# 4. Verify identity using STS (aws sts get-caller-identity identifies developer-alice)
ALICE_IDENTITY=$(alice_aws sts get-caller-identity --output json 2>/dev/null || true)
ALICE_ARN=$(echo "$ALICE_IDENTITY" | jq -r '.Arn // empty')

if [[ "$ALICE_ARN" == *":user/$USER_NAME" || "$ALICE_ARN" == *"/$USER_NAME" ]]; then
  pass "STS get-caller-identity identifies '$USER_NAME' (ARN: $ALICE_ARN)"
else
  fail "Expected STS identity for '$USER_NAME', got: ${ALICE_ARN:-<none>}"
fi

# 5. Test S3 bucket listing (expect AccessDenied)
S3_OUTPUT=$(alice_aws s3api list-buckets 2>&1 || true)
if echo "$S3_OUTPUT" | grep -qi "AccessDenied"; then
  pass "S3 bucket listing returned AccessDenied as expected"
else
  fail "Expected AccessDenied on S3 list-buckets, got: $S3_OUTPUT"
fi

# 6. Test IAM user listing (expect AccessDenied)
IAM_OUTPUT=$(alice_aws iam list-users 2>&1 || true)
if echo "$IAM_OUTPUT" | grep -qi "AccessDenied"; then
  pass "IAM user listing returned AccessDenied as expected"
else
  fail "Expected AccessDenied on IAM list-users, got: $IAM_OUTPUT"
fi

# 7. Verify access key metadata as administrator
KEYS_META=$(admin_aws iam list-access-keys --user-name "$USER_NAME" --output json 2>/dev/null || true)
FOUND_KEY_STATUS=$(echo "$KEYS_META" | jq -r --arg kid "$CREATED_KEY_ID" '(.AccessKeyMetadata // [])[] | select(.AccessKeyId == $kid) | .Status' | head -n 1)

if [ "$FOUND_KEY_STATUS" = "Active" ] || [ "$FOUND_KEY_STATUS" = "Inactive" ]; then
  pass "Administrator verified access key metadata (KeyId: $CREATED_KEY_ID, Status: $FOUND_KEY_STATUS)"
else
  fail "Could not verify metadata for access key '$CREATED_KEY_ID' as administrator"
fi

echo "------------------------------------------------------------------------"
if [ "$FAILURES" -eq 0 ]; then
  echo "RESULT: ALL CHECKS PASSED ($USER_NAME)"
  exit 0
else
  echo "RESULT: $FAILURES CHECK(S) FAILED ($USER_NAME)"
  exit 1
fi