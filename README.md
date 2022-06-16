# OneIM Docker Scripts

This is rather for reference than actual usage ;) Works with 8.1.x, theoretically working with but untested for 8.2.x

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
- Apiserver listens on 19&lt;version&gt; (Script not provided yet)
- Webserver listens on 16&lt;version&gt;

Some directories ($HOME/Progs/Containers) have to exist. As far as I remember,  but I have not restested this, sql server data directory needs to be chmod'ed 777. 

