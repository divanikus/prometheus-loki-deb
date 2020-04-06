#!/bin/bash

NAME=prometheus
VERSION=2.17.1

WHATIS1="prometheus - The Prometheus monitoring server"
WHATIS2="promtool - Tooling for the Prometheus monitoring system"
WHATIS3="tsdb - CLI to the Prometheus TSDB"

curl -OL https://github.com/prometheus/$NAME/releases/download/v$VERSION/$NAME-$VERSION.linux-amd64.tar.gz
tar -zxvf $NAME-$VERSION.linux-amd64.tar.gz
mv $NAME-$VERSION.linux-amd64/ $NAME

$NAME/prometheus --help-man > $NAME/prometheus.1
$NAME/promtool --help-man > $NAME/promtool.1
$NAME/tsdb --help-man > $NAME/tsdb.1
# Remove build user/build date/go version headers, which is ugly.
sed -i -e '/^  /d' $NAME/prometheus.1 $NAME/promtool.1 $NAME/tsdb.1
# Fix whatis entry.
sed -i "/^.SH \"NAME\"/,+1c.SH \"NAME\"\n$WHATIS1" $NAME/prometheus.1
sed -i "/^.SH \"NAME\"/,+1c.SH \"NAME\"\n$WHATIS2" $NAME/promtool.1
sed -i "/^.SH \"NAME\"/,+1c.SH \"NAME\"\n$WHATIS3" $NAME/tsdb.1
gzip $NAME/prometheus.1
gzip $NAME/promtool.1
gzip $NAME/tsdb.1

fpm -s dir -t deb -n $NAME -v $VERSION --url https://prometheus.io/ --deb-compression xz -a amd64 \
    --deb-default debian/default --after-install debian/postinst --after-remove debian/postrm \
    --config-files /etc/prometheus/prometheus.yml \
    --config-files /etc/prometheus/consoles \
    --config-files /etc/prometheus/console_libraries \
    --config-files /etc/logrotate.d/prometheus \
    debian/default=/etc/default/$NAME \
    debian/service=/lib/systemd/system/prometheus.service \
    debian/logrotate=/etc/logrotate.d/prometheus \
    $NAME/prometheus=/usr/bin/prometheus \
    $NAME/promtool=/usr/bin/promtool \
    $NAME/tsdb=/usr/bin/tsdb \
    $NAME/prometheus.yml=/etc/prometheus/prometheus.yml \
    $NAME/consoles=/etc/prometheus/consoles \
    $NAME/console_libraries=/etc/prometheus/console_libraries \
    $NAME/prometheus.1.gz=/usr/share/man/man1/prometheus.1.gz \
    $NAME/promtool.1.gz=/usr/share/man/man1/promtool.1.gz \
    $NAME/tsdb.1.gz=/usr/share/man/man1/tsdb.1.gz

rm -rf $NAME/ *.tar.gz
mv *.deb ..