#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -lt 1 ]; then
  echo "Usage: $0 <iam-username> [expected-path] [expected-tag-key=expected-tag-value ...]"
  echo "Example: $0 developer-alice /developers/ Team=Developers Environment=Lab"
  exit 1
fi

USER="$1"
shift

EXPECTED_PATH=""
EXPECTED_TAGS=()

# Optional 2nd arg: expected path (e.g., /developers/ or developers/)
if [ "$#" -gt 0 ] && [[ "$1" == /* || "$1" == */ ]]; then
  EXPECTED_PATH="$1"
  shift
fi

# Remaining args: expected tags in Key=Value format
if [ "$#" -gt 0 ]; then
  EXPECTED_TAGS=("$@")
fi

FAILURES=0

pass() {
  echo "[PASS] $1"
}

fail() {
  echo "[FAIL] $1"
  FAILURES=$((FAILURES + 1))
}

echo "Verifying IAM user: $USER"
echo "----------------------------------------"

# 1. IAM user exists + 2. Username and path + 3. ARN and unique ID + 9. Tags
USER_JSON=$(aws iam get-user --user-name "$USER" --output json 2>/dev/null || true)

if [ -z "$USER_JSON" ]; then
  fail "IAM user '$USER' does not exist or cannot be retrieved"
  fail "Username and path verification skipped (user missing)"
  fail "ARN and unique ID retrieval skipped (user missing)"
  fail "Tags verification skipped (user missing)"
else
  pass "IAM user '$USER' exists"

  ACTUAL_USER_NAME=$(echo "$USER_JSON" | jq -r '.User.UserName')
  ACTUAL_PATH=$(echo "$USER_JSON" | jq -r '.User.Path')
  ACTUAL_ARN=$(echo "$USER_JSON" | jq -r '.User.Arn')
  ACTUAL_USER_ID=$(echo "$USER_JSON" | jq -r '.User.UserId')

  pass "ARN: $ACTUAL_ARN | Unique ID (UserId): $ACTUAL_USER_ID"

  if [ -n "$EXPECTED_PATH" ]; then
    # Normalize leading/trailing slashes so '/developers/' and 'developers/' both match cleanly
    NORM_ACTUAL_PATH="/${ACTUAL_PATH#/}"
    NORM_ACTUAL_PATH="${NORM_ACTUAL_PATH%/}/"
    NORM_EXPECTED_PATH="/${EXPECTED_PATH#/}"
    NORM_EXPECTED_PATH="${NORM_EXPECTED_PATH%/}/"

    if [ "$ACTUAL_USER_NAME" = "$USER" ] && [ "$NORM_ACTUAL_PATH" = "$NORM_EXPECTED_PATH" ]; then
      pass "Username '$ACTUAL_USER_NAME' and path '$ACTUAL_PATH' match expected path '$EXPECTED_PATH'"
    else
      fail "Expected username '$USER' and path '$NORM_EXPECTED_PATH', got username '$ACTUAL_USER_NAME' and path '$ACTUAL_PATH'"
    fi
  else
    pass "Username '$ACTUAL_USER_NAME' and path '$ACTUAL_PATH' retrieved"
  fi

  # 9. Tags are correct
  if [ "${#EXPECTED_TAGS[@]}" -gt 0 ]; then
    TAG_MISMATCH=0
    for PAIR in "${EXPECTED_TAGS[@]}"; do
      EXPECTED_KEY="${PAIR%%=*}"
      EXPECTED_VAL="${PAIR#*=}"
      ACTUAL_VAL=$(echo "$USER_JSON" | jq -r --arg k "$EXPECTED_KEY" '(.User.Tags // [])[] | select(.Key == $k) | .Value' | head -n 1)

      if [ -z "$ACTUAL_VAL" ]; then
        fail "Missing expected tag '$EXPECTED_KEY'"
        TAG_MISMATCH=1
      elif [ "$ACTUAL_VAL" != "$EXPECTED_VAL" ]; then
        fail "Tag '$EXPECTED_KEY' expected '$EXPECTED_VAL', got '$ACTUAL_VAL'"
        TAG_MISMATCH=1
      fi
    done

    if [ "$TAG_MISMATCH" -eq 0 ]; then
      pass "All expected tags match"
    fi
  else
    TAGS_SUMMARY=$(echo "$USER_JSON" | jq -c '.User.Tags // []')
    pass "Tags retrieved: $TAGS_SUMMARY"
  fi
fi

# 4. No managed policies are attached
ATTACHED_POLICIES=$(aws iam list-attached-user-policies --user-name "$USER" --query 'AttachedPolicies' --output text 2>/dev/null || echo "ERROR")
if [ "$ATTACHED_POLICIES" = "ERROR" ]; then
  fail "Could not list attached managed policies for '$USER'"
elif [ -z "$ATTACHED_POLICIES" ]; then
  pass "No managed policies are attached"
else
  fail "Managed policies still attached: $ATTACHED_POLICIES"
fi

# 5. No inline policies exist
INLINE_POLICIES=$(aws iam list-user-policies --user-name "$USER" --query 'PolicyNames' --output text 2>/dev/null || echo "ERROR")
if [ "$INLINE_POLICIES" = "ERROR" ]; then
  fail "Could not list inline policies for '$USER'"
elif [ -z "$INLINE_POLICIES" ]; then
  pass "No inline policies exist"
else
  fail "Inline policies still exist: $INLINE_POLICIES"
fi

# 6. No IAM groups are associated
USER_GROUPS=$(aws iam list-groups-for-user --user-name "$USER" --query 'Groups[].GroupName' --output text 2>/dev/null || echo "ERROR")
if [ "$USER_GROUPS" = "ERROR" ]; then
  fail "Could not list IAM groups for '$USER'"
elif [ -z "$USER_GROUPS" ]; then
  pass "No IAM groups are associated"
else
  fail "IAM groups still associated: $USER_GROUPS"
fi

# 7. No access keys exist
ACCESS_KEYS=$(aws iam list-access-keys --user-name "$USER" --query 'AccessKeyMetadata[].AccessKeyId' --output text 2>/dev/null || echo "ERROR")
if [ "$ACCESS_KEYS" = "ERROR" ]; then
  fail "Could not list access keys for '$USER'"
elif [ -z "$ACCESS_KEYS" ]; then
  pass "No access keys exist"
else
  fail "Access keys still exist: $ACCESS_KEYS"
fi

# 8. No console login profile exists
LOGIN_PROFILE_OUTPUT=$(aws iam get-login-profile --user-name "$USER" --output text 2>&1 || true)
if echo "$LOGIN_PROFILE_OUTPUT" | grep -q "NoSuchEntity"; then
  pass "No console login profile exists"
elif echo "$LOGIN_PROFILE_OUTPUT" | grep -q "UserName"; then
  fail "Console login profile exists for '$USER'"
else
  fail "Unexpected response checking login profile: $LOGIN_PROFILE_OUTPUT"
fi

echo "----------------------------------------"
if [ "$FAILURES" -eq 0 ]; then
  echo "RESULT: ALL CHECKS PASSED ($USER)"
  exit 0
else
  echo "RESULT: $FAILURES CHECK(S) FAILED ($USER)"
  exit 1
fi