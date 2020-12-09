#!/bin/bash

NAME=pushgateway
VERSION=1.3.0

curl -OL https://github.com/prometheus/$NAME/releases/download/v$VERSION/$NAME-$VERSION.linux-amd64.tar.gz
tar -zxvf $NAME-$VERSION.linux-amd64.tar.gz
mv $NAME-$VERSION.linux-amd64/ $NAME

$NAME/pushgateway --help-man > $NAME/pushgateway.1
# Remove build user/build date/go version headers, which is ugly.
sed -i -e '/^  /d' $NAME/pushgateway.1 
gzip $NAME/pushgateway.1

fpm -s dir -t deb -n prometheus-$NAME -v $VERSION --url https://prometheus.io/ --deb-compression xz -a amd64 \
    --after-install debian/postinst --after-remove debian/postrm \
    --config-files /etc/logrotate.d/prometheus-pushgateway \
    --config-files /etc/default/prometheus-$NAME \
    debian/default=/etc/default/prometheus-$NAME \
    debian/service=/lib/systemd/system/prometheus-pushgateway.service \
    debian/logrotate=/etc/logrotate.d/prometheus-pushgateway \
    $NAME/pushgateway=/usr/bin/prometheus-pushgateway \
    $NAME/pushgateway.1.gz=/usr/share/man/man1/prometheus-pushgateway.1.gz

rm -rf $NAME/ *.tar.gz
mv *.deb ..