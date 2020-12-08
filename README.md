Dealing with a bunch of services in a docker-compose.yaml can be difficult.

This makefile will parse a docker-compose and create rules for each service listed:
make <service>_up/down/logs/status/restart

You can also get all results by dropping the <service>_:
make up/down/logs/status/restart

There is another target for all services, "make top", to which just does "docker-compose top".

You can test your yaml formatting with "make test".

Unless you are providing "yq" for parsing yaml, be sure fetch the image with:
make update

