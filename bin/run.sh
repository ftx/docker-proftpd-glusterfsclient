#!/bin/bash

set -e
[ "$DEBUG" == "1" ] && set -x && set +e

if [ "${GLUSTER}" == "**NO**" -o -z "${GLUSTER}" ]; then
   GLUSTER=${GLUSTER}
fi

if [ "${GLUSTER_VOL}" == "ranchervol" -o -z "${GLUSTER_VOL}" ]; then
   GLUSTER_VOL=${GLUSTER_VOL}
fi

### GlusterFS
if [ "${GLUSTER}" == "YES" ]; then

if [ "${GLUSTER_PEER}" == "storage" -o -z "${GLUSTER_PEER}" ]; then
   GLUSTER_PEER=${GLUSTER_PEER}
fi

ALIVE=0
for glusterHost in ${GLUSTER_PEER}; do
    echo "=> Checking ${glusterHost} ..."
    if ping -c 10 ${glusterHost} >/dev/null 2>&1; then
       echo "=> GlusterFS node ${glusterHost} is alive"
       ALIVE=1
       break
    else
       echo "*** Could not reach server ${glusterHost} ..."
    fi
done

if [ "$ALIVE" == 0 ]; then
   echo "ERROR: could not contact any GlusterFS node from this list: ${GLUSTER_PEER} - Exiting..."
   exit 1
fi

echo "=> Mounting GlusterFS volume ${GLUSTER_VOL} from GlusterFS node ${glusterHost} ..."
mount -t glusterfs ${glusterHost}:/${GLUSTER_VOL} /ftp
fi








### FTP
if [ "${FTP}" == "**NO**" -o -z "${FTP}" ]; then
   FTP=${FTP}
fi


if [ "${FTP}" == "YES" ]; then

if [ "${FTP_LOGIN}" == "flotix" -o -z "${FTP_LOGIN}" ]; then
   FTP_LOGIN=${FTP_LOGIN}
fi

if [ "${FTP_PASSWD}" == "**ChangeMe**" -o -z "${FTP_PASSWD}" ]; then
   FTP_PASSWD=${FTP_PASSWD}
fi


# User
adduser --quiet --disabled-password -shell /bin/false --home /ftp --gecos "FTP" ${FTP_LOGIN}
echo "${FTP_LOGIN}:${FTP_PASSWD}" | chpasswd




fi

/usr/bin/supervisord
