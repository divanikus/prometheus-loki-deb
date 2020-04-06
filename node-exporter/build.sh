#!/bin/bash

NAME=node_exporter
VERSION=1.0.0-rc.0

curl -OL https://github.com/prometheus/$NAME/releases/download/v$VERSION/$NAME-$VERSION.linux-amd64.tar.gz
tar -zxvf $NAME-$VERSION.linux-amd64.tar.gz
mv $NAME-$VERSION.linux-amd64/ $NAME

$NAME/node_exporter --help-man > $NAME/node_exporter.1
# Remove build user/build date/go version headers, which is ugly.
sed -i -e '/^  /d' $NAME/node_exporter.1 
gzip $NAME/node_exporter.1

fpm -s dir -t deb -n prometheus-node-exporter -v $VERSION --url https://prometheus.io/ --deb-compression xz -a amd64 \
    --after-install debian/postinst --after-remove debian/postrm \
    --config-files /etc/logrotate.d/prometheus-node-exporter \
    --config-files /etc/default/prometheus-node-exporter \
    debian/default=/etc/default/prometheus-node-exporter \
    debian/service=/lib/systemd/system/prometheus-node-exporter.service \
    debian/logrotate=/etc/logrotate.d/prometheus-node-exporter \
    $NAME/node_exporter=/usr/bin/prometheus-node-exporter \
    $NAME/node_exporter.1.gz=/usr/share/man/man1/prometheus-node-exporter.1.gz

rm -rf $NAME/ *.tar.gz
mv *.deb ..