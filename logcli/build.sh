#!/bin/bash

NAME=logcli
VERSION=2.0.0

curl -OL https://github.com/grafana/loki/releases/download/v$VERSION/$NAME-linux-amd64.zip
unzip $NAME-linux-amd64.zip
mv $NAME-linux-amd64 $NAME

./$NAME --help-man > $NAME.1
# Remove build user/build date/go version headers, which is ugly.
sed -i -e '/^  /d' $NAME.1 
gzip $NAME.1

fpm -s dir -t deb -n loki-$NAME -v $VERSION --url https://grafana.com/oss/loki/ --deb-compression xz -a amd64 \
    $NAME=/usr/bin/$NAME \
    $NAME.1.gz=/usr/share/man/man1/$NAME.1.gz

rm -f $NAME $NAME.1.gz *.zip
mv *.deb ..