#!/usr/bin/env bash
set -e

PLUGINS=(
  "dns-dnsmadeeasy"
  "dns-dnsimple"
  "dns-ovh"
  "dns-cloudflare"
  "dns-cloudxns"
  "dns-digitalocean"
  "dns-google"
  "dns-luadns"
  "dns-nsone"
  "dns-rfc2136"
  "dns-route53"
  "dns-gehirn"
  "dns-linode"
  "dns-sakuracloud"
)

CERTBOT_VERSION="$(certbot --version | awk '{print $NF}')"


wget -O certbot-${CERTBOT_VERSION}.tar.gz https://github.com/certbot/certbot/archive/v${CERTBOT_VERSION}.tar.gz
tar xf certbot-${CERTBOT_VERSION}.tar.gz

for plugin in "${PLUGINS[@]}"; do
  cp -r certbot-${CERTBOT_VERSION}/certbot-${plugin} /opt/certbot/src/certbot-${plugin}
  tools/pip_install.py --no-cache-dir --editable /opt/certbot/src/certbot-${plugin}
done

rm -rf certbot-${CERTBOT_VERSION}.tar.gz certbot-${CERTBOT_VERSION}
