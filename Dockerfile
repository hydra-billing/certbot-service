ARG CERTBOT_TAG="latest"
FROM certbot/certbot:${CERTBOT_TAG}

ENV CERTBOT_FLAGS="--webroot --webroot-path=/usr/share/letsencrypt"
ENV CRON_SCHED="0 */12 * * *"
ENV HOOK_CMD=""
ENV VAULT_ADDR=""
ENV VAULT_TOKEN=""
ENV VAULT_CERT_PATH="secret/ssl-cert/letsencrypt"

COPY app /opt/certbot-service

RUN apk add --no-cache bash \
                       coreutils \
                       curl \
                       docker-cli \
    && /opt/certbot-service/docker/build/install_plugins.sh

ENTRYPOINT ["/opt/certbot-service/docker/entrypoint.sh"]