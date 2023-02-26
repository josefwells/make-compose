# Start services


.PHONY: list test up logs down status update docker_yq

.SECONDEXPANSION:

DC:=UID_GID=$(shell id -u):$(shell id -g) docker-compose

NFT_TOOL=../nft_tool/nft_tool.py
NFT_TOOL_OPT=--table global --chain preroute

services    :=$(shell docker-compose config --services)
all_up      :=$(addsuffix _up, $(services))
all_down    :=$(addsuffix _down, $(services))
all_pull    :=$(addsuffix _pull, $(services))
all_build   :=$(addsuffix _build, $(services))
all_logs    :=$(addsuffix _logs, $(services))
all_status  :=$(addsuffix _status, $(services))
all_restart :=$(addsuffix _restart, $(services))
all_nftadd  :=$(addsuffix _nftadd, $(services))
all_nftdel  :=$(addsuffix _nftdel, $(services))

list: docker-compose.yml
	@echo $(services)

TEST_TARGETS:=test_yamllint test_config


test: $(TEST_TARGETS)


test_yamllint: docker-compose.yml
	yamllint $^

test_config: docker-compose.yml
	docker-compose config -q

# Top level targets just depend on calling all lower level targets
up: $(all_up) 

logs: $(all_logs)

down: $(all_down)

nftadd: $(all_nftadd)

nftdel: $(all_nftdel)

pull: $(all_pull)

build: $(all_build)

status: $(all_status)

ps:
	docker-compose ps

restart: $(all_restart)

top:
	$(DC) top

define service_rule

.PHONY: $(1)_up $(1)_down $(1)_logs $(1)_status $(1)_restart $(1)_nftadd $(1)_nftdel

# Find service/service.env file and pass it to docker-compose if it exists
$(1)_ENVCMD:=$(if $(wildcard ./$(1)/$(1).env), --env-file ./$(1)/$(1).env, )


$(1)_nftadd:
	@echo Bring up network for $(1)
	$(NFT_TOOL) --add --service $(1) $(NFT_TOOL_OPT) docker-compose.yml

$(1)_nftdel:
	@echo Bring down network for $(1)
	$(NFT_TOOL) --delete --service $(1) $(NFT_TOOL_OPT) docker-compose.yml

$(1)_up: $(1)_nftadd
	@echo Bringing UP $(1)
	$(DC) $${$(1)_ENVCMD} up --build -d $(1)

$(1)_down: $(1)_nftdel
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

$(1)_ps:
	@echo Status of $(1)
	docker-compose ps $(1)

$(1)_attach:
	@echo Attach to $(1)
	@echo 'Remember, Control-P > Control-Q to detach. (^P^Q)'
	docker attach $(1)

EXEC:=/bin/bash
$(1)_exec:
	@echo Exec into $(1)
	docker exec -it $(1) $(EXEC)

endef

$(foreach service,$(services),$(eval $(call service_rule,$(service))))
