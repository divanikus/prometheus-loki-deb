#!/bin/bash

NAME=alertmanager
VERSION=0.20.0

curl -OL https://github.com/prometheus/$NAME/releases/download/v$VERSION/$NAME-$VERSION.linux-amd64.tar.gz
tar -zxvf $NAME-$VERSION.linux-amd64.tar.gz
mv $NAME-$VERSION.linux-amd64/ $NAME

$NAME/alertmanager --help-man > $NAME/alertmanager.1
$NAME/amtool --help-man > $NAME/amtool.1
# Remove build user/build date/go version headers, which is ugly.
sed -i -e '/^  /d' $NAME/alertmanager.1 $NAME/amtool.1
gzip $NAME/alertmanager.1
gzip $NAME/amtool.1

fpm -s dir -t deb -n prometheus-$NAME -v $VERSION --url https://prometheus.io/ --deb-compression xz -a amd64 \
    --after-install debian/postinst --after-remove debian/postrm \
    --config-files /etc/prometheus/alertmanager.yml \
    --config-files /etc/logrotate.d/prometheus-alertmanager \
    --config-files /etc/default/prometheus-alertmanager \
    debian/default=/etc/default/prometheus-alertmanager \
    debian/service=/lib/systemd/system/prometheus-alertmanager.service \
    debian/logrotate=/etc/logrotate.d/prometheus-alertmanager \
    $NAME/alertmanager=/usr/bin/prometheus-alertmanager \
    $NAME/amtool=/usr/bin/ammtool \
    $NAME/alertmanager.yml=/etc/prometheus/alertmanager.yml \
    $NAME/alertmanager.1.gz=/usr/share/man/man1/prometheus-alertmanager.1.gz \
    $NAME/amtool.1.gz=/usr/share/man/man1/amtool.1.gz

rm -rf $NAME/ *.tar.gz
mv *.deb ..