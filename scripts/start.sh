#! /bin/sh
chown -R $PUID:$PGID /usr/local/sbin/guacd

GROUPNAME=$(getent group $PGID | cut -d: -f1)
USERNAME=$(getent passwd $PUID | cut -d: -f1)

if [ ! $GROUPNAME ]
then
        addgroup -g $PGID guacd
        GROUPNAME=guacd
fi

if [ ! $USERNAME ]
then
        adduser -G $GROUPNAME -u $PUID -D guacd
        USERNAME=guacd
fi

su $USERNAME -c '/usr/local/sbin/guacd -b 0.0.0.0 -f'