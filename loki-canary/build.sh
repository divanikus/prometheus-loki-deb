#!/bin/bash

NAME=loki-canary
VERSION=2.0.0

curl -OL https://github.com/grafana/loki/releases/download/v$VERSION/$NAME-linux-amd64.zip
unzip $NAME-linux-amd64.zip
mv $NAME-linux-amd64 $NAME

fpm -s dir -t deb -n $NAME -v $VERSION --url https://grafana.com/oss/loki/ --deb-compression xz -a amd64 \
    --after-install debian/postinst \
    --config-files /etc/default/$NAME \
    debian/service=/lib/systemd/system/$NAME.service \
    debian/default=/etc/default/$NAME \
    $NAME=/usr/bin/$NAME

rm -f $NAME *.zip
mv *.deb ..