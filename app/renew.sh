#!/usr/bin/env bash
set -e

RENEW_HOOK_FILE_PATH="/tmp/renew-hook"


echo "Processing renew..."
rm -f $RENEW_HOOK_FILE_PATH

/opt/certbot-service/certbot_wrapper.sh renew --renew-hook="touch $RENEW_HOOK_FILE_PATH"

if [ -f "$RENEW_HOOK_FILE_PATH" ]; then
    if [ ! -z "$HOOK_CMD" ]; then
        eval $HOOK_CMD
        echo "Hook command executed"
    fi

    rm -f $RENEW_HOOK_FILE_PATH
fi

echo "Renew processed"