#!/bin/bash
# ---------------------------------------------------
# ✅ Jenkins Gmail Notification Script (msmtp version)
# ✅ Designed & Developed by: sak_shetty
# ---------------------------------------------------

LOG_DIR="./notify_logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/jenkins_notify_$(date +%F).log"

STATUS="$1"
JOB_NAME="$2"
BUILD_ID="$3"
TO_EMAIL="$4"

GMAIL_USER="${GMAIL_USER}"
GMAIL_APP_PASS="${GMAIL_APP_PASS}"

if [ -z "$STATUS" ] || [ -z "$JOB_NAME" ] || [ -z "$BUILD_ID" ] || [ -z "$TO_EMAIL" ]; then
  echo "❌ Missing arguments. Usage:" | tee -a "$LOG_FILE"
  echo "./jenkins_notify.sh <STATUS> <JOB_NAME> <BUILD_ID> <TO_EMAIL>" | tee -a "$LOG_FILE"
  exit 1
fi

# ✅ Install msmtp if missing
if ! command -v msmtp >/dev/null 2>&1; then
  echo "📦 Installing msmtp & mailutils..." | tee -a "$LOG_FILE"
  sudo apt-get update -y >> "$LOG_FILE" 2>&1
  sudo apt-get install -y msmtp mailutils >> "$LOG_FILE" 2>&1
fi

# ✅ Configure msmtp (temp file inside workspace)
cat > ./msmtprc <<EOF
defaults
auth           on
tls            on
tls_starttls   on
tls_trust_file /etc/ssl/certs/ca-certificates.crt
account        gmail
host           smtp.gmail.com
port           587
from           $GMAIL_USER
user           $GMAIL_USER
password       $GMAIL_APP_PASS
account default : gmail
logfile        $LOG_FILE
EOF

chmod 600 ./msmtprc

SUBJECT="Jenkins Build Notification - $JOB_NAME (#$BUILD_ID)"
BODY="
Hello,

Jenkins job finished.

✅ Job: $JOB_NAME
🔢 Build: $BUILD_ID
📌 Status: $STATUS
👨‍💻 Designed & Developed by: sak_shetty

Regards,
Jenkins Notification Service
"

echo "$BODY" | msmtp --debug --file=./msmtprc -a gmail "$TO_EMAIL"

echo "✅ Email sent at $(date)" | tee -a "$LOG_FILE"
exit 0
