#!/bin/sh

mkdir -p /etc/ddclient
cat <<EOF >/etc/ddclient/ddclient.conf
protocol=dyndns2,
use=web, web=checkip.dynu.com/, web-skip='Current IP Address:'
server=api.dynu.com
login="$DYNU_USERNAME"
password="$DYNU_PASSWORD"
interscorelive.webredirect.org
daemon=300
EOF

ddclient --foreground --file /etc/ddclient/ddclient.conf
