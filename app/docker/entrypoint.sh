#!/usr/bin/env bash
set -e

cmd=$@

if [ "$cmd" != "" ]; then
    echo "Command line arguments found, passing them to certbot..."

    /opt/certbot-service/certbot_wrapper.sh $cmd
else
    echo "No command line arguments passed, running renew service..."

    echo "$CRON_SCHED /opt/certbot-service/renew.sh 2>&1" | crontab -
    crond -f -d 8
fi