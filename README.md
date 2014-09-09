rax-autoscaler
==============

Uses the rackspace APIs to allow for scaling based on aggregate metrics across a cluster.
Can be used and installed on the auto-scale group members or on a dedicated management instance.

It leverages Cloud Servers Personality feature to run a launch script at boot time, namely *kickme.sh*,
which can be downloaded from the Internet (e.g. GitHub, Cloud Files).

## Installation
```
git clone git@github.com:boxidau/rax-autoscaler.git
virtualenv rax-autoscaler
cd rax-autoscaler/
source bin/activate
pip install pyrax termcolor netifaces six requests python-novaclient argparse
cp config.include config.ini
```

## Auto Scale Group set-up

Run:

```cp ./autoscale-group/as.json.template ./autoscale-group/as.json```

edit ```./autoscale-group/as.json```

Customise *Cloud Server's init script*, and base64 encode it:

```
$ cat >&1 | base64 << EOF 
> SHELL=/bin/bash
> PATH=/sbin:/bin:/usr/sbin:/usr/bin
> MAILTO=root
> * * * * * root    curl -s https://raw.githubusercontent.com/siso/rax-autoscaler/master/kickme.sh | /bin/bash > /dev/null
> EOF
U0hFTEw9L2Jpbi9iYXNoClBBVEg9L3NiaW46L2JpbjovdXNyL3NiaW46L3Vzci9iaW4KTUFJTFRPPXJvb3QKKiAqICogKiAqIHJvb3QgICAgY3VybCAtcyBodHRwczovL3Jhdy5naXRodWJ1c2VyY29udGVudC5jb20vc2lzby9yYXgtYXV0b3NjYWxlci9tYXN0ZXIva2lja21lLnNoIHwgL2Jpbi9iYXNoID4gL2Rldi9udWxsCg==
```

copy and paste base64 string in ```as.json```.

Update Launch Configuration of Auto Scale group:

```
http PUT https://{region}.autoscale.api.rackspacecloud.com/v1.0/{DDI}/groups/{auto_scale_group_id}/launch X-Auth-Token:{token} < as.json
```

### Configuration
Edit config.ini adding the following:
 - API username and key
 - Scaling group section should contain:
    - AutoScale Group UUID
    - Scale Up Policy UUID
    - Scale Down Policy UUID
    - Check type (agent.cpu, agent.load_average...)
    - Metric name (depends on the check type)

## Usage
Once configured you can invoke the autoscaler.py script with the following required arguments --region and --as-group
 - --as-group must refer to a section in the config file
 - --region is the rackspace datacenter where the autoscale group exists (SYD, HKG, DFW, IAD, ORD, LON)

You can also invoke the script with the --cluster option this should be used when this script actually runs on auto-scale group members. Otherwise if it is running on a dedicated management instance you do not require this option.

Once tested you should configure this script to run as a cron job either on a management instance or on all cluster members

## TODO

- no config file on Cloud Servers
- config file should fetched from Cloud Files: .as/{scale _group_id}
- *kickme.sh* should delete ```/etc/cron.d/kickme```
