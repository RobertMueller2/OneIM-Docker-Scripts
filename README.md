# OneIM Docker Scripts

[OneIM](https://www.oneidentity.com/products/identity-manager/)  
[OneIM Docker Images](https://hub.docker.com/u/oneidentity/)  

Yes, there's Docker compose and all that. I'm aware! I'm using these scripts to spin up OneIM environments on various laptops real quick, e.g. when I need to confirm something in the schema or reproduce something against an uncustomized vanilla version. Most of the time I wouldn't start all containers, just those that I need for that particular situation. So Docker compose doesn't exactly meet my use case, and chances are, if I start everything, my laptop's going to be slow. ;)

This repository is primarily meant for reference than actual usage ;) Works with 8.1.x, theoretically it should work with 8.2.x but I have not tested all images.

## sh scripts for a linux host

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

When running configwizard, add the target hostname (e.g. OneIMDB-81) as an alias for 127.0.0.1 to /etc/hosts and set the connection as e.g. OneIMDB-81,1481. This should avoid creation of jobs that the jobservice cannot process due to network issues.

## Powershell

TBD
