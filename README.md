Dealing with a bunch of services in a docker-compose.yaml can be difficult.

This makefile will parse a docker-compose and create rules for each service listed:
make <service>_up/down/logs/status/restart

You can also get all results by dropping the <service>_:
make up/down/logs/status/restart

There is another target for all services, "make top", to which just does "docker-compose top".

You can test your yaml formatting with "make test".


This make structure also assumes you need to handle adding/removing nftables rules for your docker interface.
This is the case when your docker is configured (in docker.json) with:
    "iptables":false,
    "userland-proxy": false

You must know a lot about networking!
Update the makefile variables with your nftable table name, and pre-routing chain.