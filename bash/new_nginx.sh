#! /bin/bash
TARGETDIR="/etc/nginx/sites-available"
LOGSDIR="/var/log/nginx"
DOCROOT="/var/www"

function make_index
{
cat <<- _EOF_
<html>
<head><title>$DOMAIN</title></head>
<body>Welcome to $DOMAIN</body>
</html>
_EOF_
}

function make_vhost
{
cat <<- _EOF_
server {
        listen 80;
        server_name $DOMAIN www.$DOMAIN;
        access_log /var/log/nginx/$DOMAIN.access.log;

        #
        # Uncomment if you're using fastcgi
        #
        #location ~ \.php$ {
        # fastcgi_pass 127.0.0.1:9000;
        # fastcgi_index index.php;
        # fastcgi_param SCRIPT_FILENAME /var/www/$DOMAIN\$fastcgi_script_name;
        # include fastcgi_params;
        #}

        location / {
                root /var/www/$DOMAIN;
                index index.php;
        }
}
_EOF_
}

if [ -z "$1" ]; then
echo "Usage: $0 domainname.tld"
exit 0
else
DOMAIN=$1
TARGET=$TARGETDIR/$DOMAIN
LOGS=$LOGSDIR/$DOMAIN

echo "Setting up vhost for $DOMAIN..."

if [ -f $LOGS ]; then
echo "Error: logs already exists in $TARGETDIR! Exiting..."
exit 0
fi

if [ -f $TARGET ]; then
echo "Error: vhost already exists in $TARGETDIR! Exiting..."
exit 0
else
mkdir -vp $DOCROOT/$DOMAIN
touch $LOGSDIR/$DOMAIN.access.log
make_index > $DOCROOT/$DOMAIN/index.html
make_vhost > $TARGET
fi

ln -s $TARGETDIR/$DOMAIN $TARGETDIR/../sites-enabled/$DOMAIN
echo "Done."
fi
exit
