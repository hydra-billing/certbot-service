#!/usr/bin/env bash
set -e

CERT_DIR_PATH="/etc/letsencrypt/live"

function join_array { local IFS="$1"; shift; echo "$*"; }

function mark_certs_for_saving {
    for d in $CERT_DIR_PATH/*/; do
        local domain="$(basename "$d")"
        local renew_timestamp="$(stat -c %Y $d)"

        if ((renew_timestamp >= run_timestamp)); then
            rm -f $d/vault.svd
            echo "$domain marked for saving in Vault"
        fi
    done
}

function save_certs {
    for d in $CERT_DIR_PATH/*/; do
        local domain="$(basename "$d")"

        if [ ! -f $d/vault.svd ] && (ls $d/*.pem >/dev/null 2>&1); then
            echo "Saving data for $domain to Vault..."

            save_cert "$domain"
            touch $d/vault.svd
        fi
    done
}

function save_cert {
    local domain="$1"
    local p_chunks=()

    for f in $CERT_DIR_PATH/$domain/*.pem; do
        local f_base="$(basename $f)"
        local f_name="${f_base%.*}"
        local f_content="$(sed -e ':a' -e 'N' -e '$!ba' -e 's/\n/\\n/g' $f)"
        
        local p_chunk="\"$f_name\":\"$f_content\""
        local p_chunks+=("$p_chunk")
    done

    local p_chunks_joined="$(join_array "," "${p_chunks[@]}")"
    local payload="{$p_chunks_joined}"

    curl -s -H "X-Vault-Token: $VAULT_TOKEN" -H "Content-Type: application/json" -X POST --fail --show-error \
        -d "$payload" "$VAULT_ADDR/v1/$VAULT_CERT_PATH/$domain"
}


run_timestamp="$1"

mark_certs_for_saving
save_certs