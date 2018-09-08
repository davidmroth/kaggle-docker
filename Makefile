
# A good Makefile reference - http://nibblestew.blogspot.com/2017/12/a-simple-makefile-is-unicorn.html
.SILENT: clean
.PHONY: default run showenv clean deep_clean

DOCKER_FILE_INLCUDES_DIR=build
DOCKERFILE_MAIN=$(patsubst %, $(DOCKER_FILE_INLCUDES_DIR)/%, main.dockerfile)
CONF_FILE=docker.conf

SHELL := /bin/bash

# Import and parse Env Vars - https://unix.stackexchange.com/questions/235223/makefile-include-env-file
include $(CONF_FILE)
export $(shell sed 's/=.*//' $(CONF_FILE))

ifndef NAME
	$(error 'NAME' not defined in config file: $(CONF_FILE)!)
endif

DOCKER_FILES := $(shell find $(DOCKER_FILE_INLCUDES_DIR) -name *.Dockerfile -or -name *.Dockersecret)
#$(warning $(DOCKER_FILES))

# Default at the top
default: .running

run: .running
.running: .built
	@echo -e "\nStarting Docker contaner: '$(NAME)'"
	@./run.sh && touch .running

build: .built
.built: Dockerfile
	@echo -e "\nBuilding image: '$(NAME)'..."
	@docker build -t $(NAME) . && touch .built

Dockerfile: $(DOCKERFILE_MAIN) $(DOCKER_FILES)
	m4 -I $(DOCKER_FILE_INLCUDES_DIR) $< > Dockerfile

upgrade:
	@echo "$(NAME)"
	@echo "$(shell docker ps -aq)"
	@echo "$(shell docker ps -aq | grep $(NAME))"
	IMAGES=$(shell docker ps -a | grep $(NAME))
	@echo "$(IMAGES)"
	@if test -n "$(IMAGES)"; then \
		echo -e "\nUpgrading container: '$(NAME)'..."; \
		for cmd in stop rm; do \
			if test "$$cmd" == "stop"; then \
				echo "Stopping $(RNAME)..."; \
				docker $$cmd $(RNAME) > /dev/null; \
			elif test "$$cmd" == "rm"; then \
				echo "Removing image: '$(RNAME)'..."; \
				docker $$cmd $(RNAME) > /dev/null; \
			fi; \
		done; \
	else \
		echo -e "Docker image: '$(NAME)' not found.\n"; \
		exit 0; \
	fi

clean:
	@echo -e "\nRemoving Dockerfile..."
	@rm -f Dockerfile .built .running

realclean: clean
	@images=$$(docker ps -aq); \
  if test -n "$$images"; then \
			for image_id in "$$images"; do \
				echo "Removing image ID: $$image_id..."; \
      	docker stop $$image_id >/dev/null 2>&1; \
      	docker rm $$image_id >/dev/null 2>&1; \
			done; \
  fi

askclean: clean
	@echo -e "\nAre you sure you want to remove all containers (y/n)? "
	@read -r answer; \
	if test "$$answer" != "$${answer#[Yy]}"; then \
		images=$$(docker ps -aq); \
	  if test -n "$$images"; then \
				for image_id in "$$images"; do \
					echo "Removing image ID: $$image_id..."; \
	      	docker stop $$image_id >/dev/null 2>&1; \
	      	docker rm $$image_id >/dev/null 2>&1; \
				done; \
	  fi; \
	fi

showenv:
	@env
