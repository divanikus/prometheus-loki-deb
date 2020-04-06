#!/bin/bash

NAME=loki
VERSION=1.4.0

curl -OL https://github.com/grafana/loki/releases/download/v$VERSION/$NAME-linux-amd64.zip
unzip $NAME-linux-amd64.zip
mv $NAME-linux-amd64 $NAME

fpm -s dir -t deb -n $NAME -v $VERSION --url https://grafana.com/oss/loki/ --deb-compression xz -a amd64 \
    --deb-default debian/default --after-install debian/postinst --after-remove debian/postrm \
    --config-files /etc/loki/$NAME.yml \
    debian/service=/lib/systemd/system/$NAME.service \
    debian/$NAME.yml=/etc/loki/$NAME.yml \
    $NAME=/usr/bin/$NAME

rm -f $NAME *.zip
mv *.deb ..