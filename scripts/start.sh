#! /bin/sh
chown -R $PUID:$PGID /usr/local/sbin/guacd

GROUPNAME=$(getent group $PGID | cut -d: -f1)
USERNAME=$(getent passwd $PUID | cut -d: -f1)

if [ "${GROUPNAME}" = "" ]
then
        groupadd -g $PGID guacd
        GROUPNAME=guacd
fi

if [ "${USERNAME}" = "" ]
then
        useradd -m -G $GROUPNAME -u $PUID guacd
        USERNAME=guacd
fi

su -g $GROUPNAME $USERNAME -c '/usr/local/sbin/guacd -b 0.0.0.0 -f'