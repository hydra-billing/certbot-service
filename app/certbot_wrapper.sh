#!/usr/bin/env bash

run_timestamp="$(date +%s)"

certbot "$@" $CERTBOT_FLAGS

if [ ! -z "$VAULT_ADDR" ]; then
    /opt/certbot-service/vault_process.sh "$run_timestamp"
fi