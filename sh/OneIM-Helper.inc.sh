ONEIM=$1

if [ -z "$ONEIM" ];then
    . $HOME/.config/OneIM-latest
fi

echo $ONEIM | grep -q "[1-9][0-9][0-9]\?" || {
    echo "$ONEIM is an invalid version"
    exit 120
}

if [ -z $ONEIMADDR ]; then
    sudo echo "trying to retrieve OneIMDB-${ONEIM} IP Address"
    
    ONEIMADDR=$(sudo docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' OneIMDB-${ONEIM})
fi

ONEIMVERSION=$(echo $ONEIM | sed \
    -e 's,^81$,8.1.1,g' \
    -e 's,^82$,8.2,g' \
)
