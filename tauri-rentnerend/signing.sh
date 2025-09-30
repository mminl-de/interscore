#!/bin/sh
# Runs the signing procedure.
#
# NOTE: You need to follow the steps here first:
# https://tauri.app/distribute/sign/android/#configure-gradle-to-use-the-signing-key

UPLOAD_KEYSTORE=~/upload-keystore.jks

help() {
	echo "Usage: $0 (init|deinit)"
	exit 1
}

if [ $# -eq 0 ]; then help; fi

case $1 in
	"init")
		;;
	"deinit")
		rm -v ~/upload-keystore.jks
		exit
		;;
	*)
		help
		exit
		;;
esac

password=$(tr -dc "A-Za-z0-9" < /dev/urandom | head -c8)

cat << EOF | keytool -genkey -v -keystore $UPLOAD_KEYSTORE -keyalg RSA \
	-keysize 2048 -validity 10000 -alias upload
$password
$password
<name>
<organizational unit>
<organization name>
<city>
<state>
<country code>
yes
EOF

cat << EOF > src-tauri/gen/android/keystore.properties
password=$password
keyAlias=upload
storeFile=$UPLOAD_KEYSTORE
EOF
