# Start services


.PHONY: list test up logs down status update docker_yq

.SECONDEXPANSION:

YQ:=docker run --rm -v "$(PWD):$(PWD)" -w="$(PWD)" --entrypoint yq linuxserver/yq

DC:=UID_GID=$(shell id -u):$(shell id -g) docker-compose

services    :=$(shell $(YQ) -r '.services|keys[]' docker-compose.yml)
all_up      :=$(addsuffix _up, $(services))
all_down    :=$(addsuffix _down, $(services))
all_pull    :=$(addsuffix _pull, $(services))
all_build   :=$(addsuffix _build, $(services))
all_logs    :=$(addsuffix _logs, $(services))
all_status  :=$(addsuffix _status, $(services))
all_restart :=$(addsuffix _restart, $(services))

list: docker-compose.yml
	@echo $(services)

test: docker-compose.yml
	yamllint $^

# Top level targets just depend on calling all lower level targets
up: $(all_up) 

logs: $(all_logs)

down: $(all_down)

pull: $(all_pull)

build: $(all_build)

status: $(all_status)

restart: $(all_restart)


top:
	$(DC) top

update: docker_yq

docker_yq:
	docker pull linuxserver/yq:latest

define service_rule

.PHONY: $(1)_up $(1)_down $(1)_logs $(1)_status

# Find service/service.env file and pass it to docker-compose if it exists
$(1)_ENVCMD:=$(if $(wildcard ./$(1)/$(1).env), --env-file ./$(1)/$(1).env, )

$(1)_up:
	@echo Bringing UP $(1)
	$(DC) $${$(1)_ENVCMD} up --build -d $(1)

$(1)_down:
	@echo Bringing DOWN $(1)
	$(DC) $${$(1)_ENVCMD} rm --force --stop -v $(1)

$(1)_pull:
	@echo Pulling updated $(1)
	$(DC) $${$(1)_ENVCMD} pull $(1)

$(1)_build:
	@echo Building/Pulling $(1)
	$(DC) $${$(1)_ENVCMD} build --pull $(1)

$(1)_restart:
	@echo Restarting $(1)
	$(DC) rm --force --stop -v $(1)
	$(DC) $${$(1)_ENVCMD} up --build -d $(1)

$(1)_logs:
	@echo Logs for $(1)
	$(DC) $${$(1)_ENVCMD} logs $(1)

$(1)_status:
	@echo Status of $(1)
	docker ps --filter name=$(1)

$(1)_attach:
	@echo Attach to $(1)
	@echo 'Remember, Control-P > Control-Q to detach. (^P^Q)'
	docker attach $(1)

endef

$(foreach service,$(services),$(eval $(call service_rule,$(service))))
