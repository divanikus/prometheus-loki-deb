#!/bin/bash

NAME=promtail
VERSION=1.5.0

curl -OL https://github.com/grafana/loki/releases/download/v$VERSION/$NAME-linux-amd64.zip
unzip $NAME-linux-amd64.zip
mv $NAME-linux-amd64 $NAME

fpm -s dir -t deb -n loki-$NAME -v $VERSION --url https://grafana.com/oss/loki/ --deb-compression xz -a amd64 \
    --config-files /etc/loki/$NAME.yml \
    --config-files /etc/default/loki-$NAME \
    debian/default=/etc/default/loki-$NAME \
    debian/service=/lib/systemd/system/loki-$NAME.service \
    debian/$NAME.yml=/etc/loki/$NAME.yml \
    $NAME=/usr/bin/loki-$NAME

rm -f $NAME *.zip
mv *.deb ..