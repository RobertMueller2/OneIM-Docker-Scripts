# OneIM Docker Scripts

[OneIM](https://www.oneidentity.com/products/identity-manager/)  
[OneIM Docker Images](https://hub.docker.com/u/oneidentity/)  

Originally these were created for Docker, I've now converted them to use podman and I was too lazy to rename the repository. Check the commit history if you need to use docker.

Yes, there's compose files and all that. I'm aware! I'm using these scripts to spin up OneIM environments on various laptops real quick, e.g. when I need to confirm something in the schema or reproduce something against an uncustomized vanilla version. Most of the time I wouldn't start all containers, just those that I need for that particular situation. Using compose files didn't look like that much of an advantage so I skipped that for the time being.

This repository is primarily meant for reference than actual usage ;) Works with 8.1.x, theoretically it should work with 8.2.x but I have not tested all images.

## Linux Host
### sh scripts

The scripts take one optional parameter, e.g. 81, 82, 90, 101 referring to a OneIM release (without SP).

To make it optional, default version must be provided in $HOME/.config/OneIM-latest, e.g.

```sh
echo "ONEIM=82" > $HOME/.config/OneIM-latest
```

To get the correct ONEIMVERSION docker image, OneIM-Helper.inc.sh does some sed based replacement of the version provided above, e.g. 81 -> 8.1.1, 82 -> 8.2.

- DB listens on 14&lt;version&gt;
- Jobservice listens on 18&lt;version&gt;
- Appserver listens on 17&lt;version&gt;
- Apiserver listens on 19&lt;version&gt;
- Webserver listens on 16&lt;version&gt;

Some directories ($HOME/Progs/Containers) have to exist. As far as I remember,  but I have not restested this, sql server data directory needs to be chmod'ed 777. 

When running configwizard, add the target hostname (e.g. OneIMDB-81) as an alias for 127.0.0.1 to /etc/hosts and set the connection as e.g. OneIMDB-81,1481. This should avoid creation of jobs that the jobservice cannot process due to network issues. Alternatively, configure jobservice with specific connection info (QBMServer.UID_QBMConnectionInfo) later on.

### Networking

The containers use a network alias OneIMDB-&lt;version&lt; pointing to the host loopback address 10.0.2.2 to communicate with the DB.

Podman imports the host's /etc/hosts to the container, then applies the host alias supplied with the --add-host option in the scripts. This creates a bit of a challenge whenever adding a connection string with setup/configwizard. One one hand, you'd want to provide OneIMDB-&lt;version&gt; in the connection string, so all the jobs are generated for an address that the jobservice can resolve. But if you are running the frontend from the same host (on a Linux host, with wine), you'd have to add an alias for OneIMDB-&lt;version&gt; pointing to 127.0.0.1. This means, in the containers, the hostname OneIMDB-&lt;version&gt; is not unique. The network stack will try both addresses, but this configuration inevitably leads to unnecessary tcp connects.

Workarounds:
- run the frontends from a VM and place an appropriate host alias for OneIMDB-<version> there
- edit host's /etc/hosts file temporarily for placing connection string in the database
- use a docker container to run the frontends with wine. I should imagine it's some hassle to setup, but since OneIM fat clients do work witn wine (.NET framework but not mono) and containers are known to support graphical applications, it certainly sounds possible. This container could again have a host alias for OneIMDB-<version> pointing to 10.0.2.2.
- use podman > 4.1 and check out the base_hosts_file option in containers.conf

### Troubleshooting

mssql container runs with user mssql, but volume ownership of the user running the container is mapped to root inside. As far as I can tell, creating the volume root group writable is sufficient. For troubleshooting, `podman unshare` might be a first step.

All scripts can take literal "dry" as a parameter before the version. In that case, the script prints the container run command instead of issuing it.

## Powershell

TBD

## Notes
8.2 onwards requires a Trusted Source Key for web portal and API server. There is a default in the shell scripts, and that needs to match what's configured in QBMWebApplication.

### disable custom error messages

When things go wrong in the web applications, the custom error messages make it difficult to investigate. There's no proper editor like vi ;) available in the containers, but you can use sed to replace the pertient config option like below. The application should restart itself due to the file change.

```sh
$ sudo docker exec -it <container id> /bin/bash
root@<container id># sed -i -e 's,customErrors mode="On",customErrors mode="Off",g' web.config
```

Alternatively, you can run `apt update` and install nano, vim, etc...

## Known issues

- after changing to podman, starting new containers was not tested. there might be one or the other issue with creating the paths.
- 8.2.1 oneim-web does not respond  
- 9.0 not tested yet  

