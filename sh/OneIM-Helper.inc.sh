
create_container_subdir_web () {
  uid=$1
  shift

  for d in $@ ; do
    if [ ! -d "$CONTAINER"/$d ]; then
      mkdir -p $CONTAINER/$d
      podman unshare chown $uid $CONTAINER/$d
    fi
  done
}

DRY=
if [ "$1" = "dry" ]; then
    DRY=echo
    shift
fi

ONEIM=$1
ONEIMCONF="$HOME/.config/podman-OneIM.inc.sh"

if [ ! -f "$ONEIMCONF" ];then
    echo "Error: ${ONEIMCONF} does not exist. Consider" >&2
    echo "echo ONEIMDEFAULTVERSION=90 >> ${ONEIMCONF}" >&2
    echo "echo CONTAINERDATA=\$HOME/Containers >> ${ONEIMCONF}"
    exit 240
fi

. $ONEIMCONF || exit 230

if [ -z "$CONTAINERDATA" ];then
    echo "Error: CONTAINERDATA not specified, e.g." >&2
    echo "echo CONTAINERDATA=\$HOME/Containers >> ${ONEIMCONF}" >&2
    exit 239
fi

if [ -z "$ONEIMDEFAULTVERSION" ];then
    echo "Warning: ONEIMDEFAULTVERSION not set, e.g."
    echo "echo ONEIMDEFAULTVERSION=90 >> ${ONEIMCONF}" >&2
fi

if [ -z "$ONEIM" ];then
    ONEIM=$ONEIMDEFAULTVERSION
fi

echo $ONEIM | grep -q "[1-9][0-9][0-9]\?" || {
    echo "$ONEIM is an invalid version" >&2
    exit 120
}

#if [ -z $ONEIMADDR ]; then
#    echo "trying to retrieve OneIMDB-${ONEIM} IP Address"
#    
#    ONEIMADDR=$(docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' OneIMDB-${ONEIM})
#fi

ONEIMVERSION=$(echo $ONEIM | sed \
    -e 's,^81$,8.1.1,g' \
    -e 's,^82$,8.2,g' \
    -e 's,^90,9.0,g' \
    -e 's,^91,9.1,g' \
    -e 's,^92,9.2,g')
