Dealing with a bunch of services in a docker-compose.yaml can be difficult.

This makefile will parse a docker-compose and create rules for each service listed:
make <service>_up/down/logs/journal/status/restart/build/pull

Command line completion makes it easy to type a little of your service-name and <tab>

You can also get all results by dropping the <service>_:
make up/down/logs/status/restart

There is another target for all services, "make top", to which just does "docker-compose top".
Even more concise is "make ps", which again just does "docker-compose ps".

You can test your yaml formatting with "make test".


Networking
==========
If you don't want this, just set NFT_TOOL=true in the makefile.


This make structure also assumes you need to handle adding/removing nftables rules for your docker interface.
This is the case when your docker is configured (in docker.json) with:
    "iptables":false,
    "userland-proxy": false

You must know a lot about networking!
Update the makefile variables with your nftable table name, and pre-routing chain.
You will want to clone the nft_tool repo: https://github.com/josefwells/nft_tool


Logs
====
To see logs from a container run:
 make <container>_logs

Due to the way we run/remove old containers, these logs are not reachable once a
container is brought down.  Not super helpful when you are trying to figure out
what is going on with a container that fails, etc.

If you want some logs to persist, you can log to journald by editing /etc/docker/daemon.json
    "log-driver": "journald"

Then I've added:
 make <container>_journal
