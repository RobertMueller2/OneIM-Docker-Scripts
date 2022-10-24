# OneIM Docker Scripts

[OneIM](https://www.oneidentity.com/products/identity-manager/)  
[OneIM Docker Images](https://hub.docker.com/u/oneidentity/)  

Originally these were created for Docker, I've now converted the sh scripts to use podman and I was too lazy to rename the repository. Check the commit history if you need to use docker.

Yes, there's compose files and all that. I'm aware! I'm using these scripts to spin up OneIM environments on various laptops real quick, e.g. when I need to confirm something in the schema or reproduce something against an uncustomized vanilla version. Most of the time I wouldn't start all containers, just those that I need for that particular situation. Using compose files didn't look like that much of an advantage so I skipped that for the time being.

This repository is primarily meant for reference than actual usage ;)

I've successfully tested the Linux scripts with 8.1.1 (8.1.5 DB) and 9.0.

## Linux Host
### sh scripts

The scripts take one optional parameter, e.g. 81, 82, 90 referring to a OneIM release (without SP).

The parameter is only optional if a default version is specificed. Also, the scripts need to know where to create the persisting container directories. This is configured in `$HOME/.config/podman-OneIM.inc.sh` with the env vars `CONTAINERDATA` and `ONEIMDEFAULTVERSION`, e.g. your file could look like this:

```sh
CONTAINERDATA=$HOME/Containers
ONEIMDEFAULTVERSION=90
```

The scripts do some replacement to turn versions into image versions, e.g. 81 to 8.1.1, 90 to 9.0, etc. Of course this needs to be maintained down the road. ;)

The ports for the services depend on the version, so theoretically several releases could run at the same time:

- DB listens on 14&lt;version&gt;
- Jobservice listens on 18&lt;version&gt;
- Appserver listens on 17&lt;version&gt;
- Apiserver listens on 19&lt;version&gt;
- Webserver listens on 16&lt;version&gt;

The hostname is also formed from the version, e.g. OneIMDB-90, OneIMDB-81 etc. When running configwizard, add the target hostname as an alias for 127.0.0.1 to /etc/hosts and set the connection as e.g. OneIMDB-81,1481. This should avoid creation of jobs that the jobservice cannot process due to network issues (but please see next section, because this is not entirely issue-free). Alternatively, configure jobservice with specific connection info (QBMServer.UID_QBMConnectionInfo) later on.

### Networking

The containers also use the network alias OneIMDB-&lt;version&gt; pointing to the host loopback address 10.0.2.2 to communicate with the DB.

Podman imports the host's /etc/hosts to the container, then applies the host alias supplied with the --add-host option in the scripts. This creates a bit of a challenge whenever adding a connection string with setup/configwizard. One one hand, you'd want to provide OneIMDB-&lt;version&gt; in the connection string, so all the jobs are generated for an address that the jobservice can resolve. But if you are running the frontend from the same host (on a Linux host, with wine), you'd have to add an alias for OneIMDB-&lt;version&gt; pointing to 127.0.0.1. This means, in the containers, the hostname OneIMDB-&lt;version&gt; is not unique. The network stack will try both addresses, but this configuration inevitably leads to unnecessary tcp connects.

Workarounds:
- run the frontends from a VM and place an appropriate host alias for OneIMDB-&lt;version&gt; there
- edit host's /etc/hosts file temporarily for placing connection string in the database
- use a docker container to run the frontends with wine. I should imagine it's some hassle to setup, but since OneIM fat clients do work with wine (.NET framework but not mono) and containers are known to support graphical applications, it certainly sounds possible. This container could again have a host alias for OneIMDB-<version> pointing to 10.0.2.2.
- use podman > 4.1 and check out the base_hosts_file option in containers.conf

### Troubleshooting

mssql container runs with user mssql, but volume ownership of the user running the container is mapped to root inside. As far as I can tell, creating the volume root group writable is sufficient. For troubleshooting, `podman unshare` might be a first step.

All scripts can take literal "dry" as a parameter before the version (e.g. `podman-OneIM-apiserver dry 90`). In that case, the script prints the container run command instead of issuing it.

### disable custom error messages

When things go wrong in the web applications, the custom error messages make it difficult to investigate. There's no proper editor like vi ;) available in the containers unless you install it, but you can use sed to replace the pertient config option like below. The application should restart itself due to the file change.

```sh
$ sudo docker exec -it <container id> /bin/bash
root@<container id># sed -i -e 's,customErrors mode="On",customErrors mode="Off",g' web.config
```

Alternatively, you can run `apt update` and install nano, vim, etc...

## Windows Host
### Powershell

TBD

## Known issues

- 8.2.1 mono server within oneim-web does not respond, I have not yet found the cause

## Notes
8.2 onwards requires a Trusted Source Key for web portal and API server. There is a default in the shell scripts, and that needs to match what's configured in QBMWebApplication.TrustedSourceKey. Unlike the web installer, the docker images (at least 8.2 and 9.0) do not set the TrustedSourceKey in the DB. Moreover, the value in the DB is supposed to be a hash and when entering the value via e.g. objectbrowser, it's stored as plain text, so that way there would be a mismatch. Fortunately, I can provide you with the hash value for the script default `D34db33F!`: `P|E|1v7fMhUANaiTUVSxS8E7+M8m|XFFhOJ02dtLbQfpqP9oqYxfum0Gg3oGaHVexYU0aDHMjTPJCKizV+g3/yozYsi9b/jHU1YrQLqdtYYcl` -- but you still have to add this to both API Server's and Web Portal's QBMWebApplication entries.

8.2 can use the oneim-dbagent (not tested), 9.0 and later needs to.


