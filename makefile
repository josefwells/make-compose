# Start services


.PHONY: list up logs down status update docker_yq


YQ:=docker run --rm -v "$(PWD):$(PWD)" -w="$(PWD)" --entrypoint yq linuxserver/yq

services:=$(shell $(YQ) -r '.services|keys[]' docker-compose.yml)

list: docker-compose.yml
	@echo $(services)

up:
	docker-compose up -d

logs:
	docker-compose logs

down:
	docker-compose down

status:
	docker-compose top


update: docker_yq


docker_yq:
	docker pull linuxserver/yq:latest


define service_rule

.PHONY: $(1)_up $(1)_down $(1)_logs $(1)_status

$(1)_up:
	@echo Bringing UP $(1)
	docker-compose up -d $(1)

$(1)_down:
	@echo Bringing DOWN $(1)
	docker-compose rm --force --stop -v $(1)

$(1)_logs:
	@echo Logs for $(1)
	docker-compose logs $(1)

$(1)_status:
	@echo Status of $(1)
	docker ps --filter name=$(1)
endef

$(foreach service,$(services),$(eval $(call service_rule,$(service))))

#$(foreach service,$(services), $(eval $(warning Hi $(service))))
