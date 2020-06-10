# Certbot Service

This project extends the official certbot docker image and made with some practices from
[ketchoop/letsencrypt-to-vault](https://github.com/ketchoop/letsencrypt-to-vault). The key features are:

1. Automatic renewal with built-in cron daemon.  
    No longer need to set up an external cron job for renewal. Just run certbot-service with no arguments and
    it will start built-in renewal cron job for you.
1. Automatic upload of obtained certificates to Hashicorp Vault.  
    If you would like, certbot-service could upload the content of all .pem files into Vault. It will be done
    for each domain only if its certificate is changed (obtained or renewed).
1. Running of custom hook command when renewal is succeeded.  
    Set up the hook command and certbot-service will run it on each renewal is succeeded. For example, you can use
    this feature to reload web server after certificates are renewed (docker-cli is inside to do it!).
1. Availability of all certbot DNS plugins.  
    Doesn't matter which way you use to verify your domain. You can use any certbot DNS plugin with certbot-service
    at the same time (webroot, route53, google, etc.)!

## Configuration

certbot-service could be configured using environment variables, which are:

1. `CERTBOT_FLAGS` (default `--webroot --webroot-path=/usr/share/letsencrypt`) — options implicitly passed to
certbot command.
1. `CRON_SCHED` (default `0 */12 * * *`) — schedule for cron daemon renew job.
1. `HOOK_CMD` — hook command executed when renewal is succeeded (e.g. `docker kill --signal=SIGHUP nginx`).
1. `VAULT_ADDR` — address of Hashicorp Vault (e.g. `https://vault.example.com:8200`). Non-empty value activates
saving certificates to Vault.
1. `VAULT_TOKEN` — access token to Vault.
1. `VAULT_CERT_PATH` (default `secret/ssl-cert/letsencrypt`) — path to certificates data in Vault.
1. All other environment variables which certbot or its plugins understand
(`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, etc.).

## Usage Examples

### Certbot with webroot plugin and nginx

Use docker-compose project from [examples/nginx](examples/nginx).

1. Run the project:

    ```
    docker-compose up -d
    ```

1. Obtain the certificate:

    ```
    docker-compose run --rm certbot-service certonly -d example.com
    ```

1. Enable SSL server in `conf.d/default.conf`.
1. Reload nginx:

    ```
    docker-compose kill -s SIGHUP nginx
    ```

That's all! You do not need to set up any additional cron job for certificates renewal, certbot-serivce
will do it for you while it is running.

### Standalone certbot with route53 DNS plugin and Vault

Use docker-compose project from [examples/standalone](examples/standalone).

1. Configure certbot-service with environment variables in `.env` file (set `VAULT_ADDR`, `VAULT_TOKEN`,
`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, etc.).
1. Run the project:

    ```
    docker-compose up -d
    ```

1. Obtain the certificate:

    ```
    docker-compose run --rm certbot-service certonly --dns-route53 -d example.com
    ```

That's all! You do not need to set up any additional cron job for certificates renewal, certbot-serivce
will do it for you while it is running.
