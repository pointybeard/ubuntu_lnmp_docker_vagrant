#!/usr/bin/env bash

if [ -z "${BASH_VERSINFO}" ] || [ -z "${BASH_VERSINFO[0]}" ] || [ ${BASH_VERSINFO[0]} -lt 4 ]; then
    echo "This script requires Bash version >= 4\n\n"; exit 1
fi

export DEBIAN_FRONTEND=noninteractive

## Make sure everything is up to date
apt-get clean && \
apt-get update -yq && \
apt-get upgrade -yq

## /run/php is removed when vm is halted. Make sure its there otherwise php-fpm won't start
mkdir -p /run/php

## (Re)Start some services
service php7.4-fpm restart
service php8.1-fpm restart
service nginx restart

## repopulate /etc/hosts
cat /vagrant/conf/hosts >> /etc/hosts
