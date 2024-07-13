ONEIMCONF="$HOME/.config/podman-OneIM.inc.sh"

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

usage() {
    echo -n "$0 [--dry] [--oneim <version>]"
    if [ -n "$ISDBSCRIPT" ];then
       echo -n " [--mssql <version>]"
    fi
    echo
    echo
    echo "--oneim can be skipped if ONEIMDEFAULTVERSION is defined in ${ONEIMCONF}."
    if [ -n "$ISDBSCRIPT" ];then
      echo "--mssql can be skipped if MSSQLDEFAULTVERSION is defined in ${ONEIMCONF}."
    fi
}

TPARAMS=$(mktemp)

while [ $# -ge 1 ]; do
    case $1 in
        --dry)
            echo "DRY=echo" >> $TPARAMS
            shift
            ;;
        --oneim)
            shift
            if ! echo $1 | grep -q "^[1-9][0-9][0-9]\?\$"; then
                echo "--oneim $1 is not a valid OneIM version"
                echo
                usage
                exit 210
            fi
            echo "ONEIM=$1" >> $TPARAMS
            shift
            ;;
        --mssql)
            shift
            # this ought to be enough, I suppose
            if ! echo $1 | grep -q "^20[0-9][0-9]\?\$"; then
                echo "--mssql $1 is not a valid SQL Server version"
                echo
                usage
                exit 210
            fi
            echo "MSSQLVERSION=$1" >> $TPARAMS
            shift
            ;;
        *)
            echo "unknown parameter $1"
            usage
            exit 209
    esac
done

eval $(cat ${TPARAMS})
rm $TPARAMS


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

if [ -z "$MSSQLDEFAULTVERSION" ];then
    echo "Warning: MSSQLDEFAULTVERSION not set, e.g."
    echo "echo MSSQLDEFAULTVERSION=2022 >> ${ONEIMCONF}" >&2
fi

ONEIM=${ONEIM:-$ONEIMDEFAULTVERSION}
MSSQLVERSION=${MSSQLVERSION:-$MSSQLDEFAULTVERSION}

if ! echo $ONEIM | grep -q "[1-9][0-9][0-9]\?"; then
    echo "$ONEIM is an invalid OneIM version" >&2
    exit 120
fi

ONEIMVERSION=$(echo $ONEIM | sed \
    -e 's,^81$,8.1.1,g' \
    -e 's,^82$,8.2,g' \
    -e 's,^90,9.0,g' \
    -e 's,^91,9.1,g' \
    -e 's,^92,9.2,g')

