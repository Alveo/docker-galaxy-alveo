
DOCKER=docker
IMAGE=stevecassidy/alveo-galaxy
HOST_IP_ADDRESS=130.56.244.156
DOCKER_MACHINE_NAME=galaxy-machine
CONTAINER_NAME=alveo_galaxy_production
TAG=latest

latest:
	$(DOCKER) build -f Dockerfile -t $(IMAGE) .

no-cache:
	$(DOCKER) build --no-cache -f Dockerfile -t $(IMAGE) .

push:
	$(DOCKER) push $(IMAGE)

tag:
	if [ -n "$(TAG)" ] ; then $(DOCKER) tag $(IMAGE) $(IMAGE):$(TAG) ; fi

run:
	$(DOCKER) run -d -p 8080:80 --privileged=true -p 8021:21 -p 8800:8800 $(IMAGE)

run-export:
	mkdir -p export
	sleep 1
	$(DOCKER) run -d -p 8080:80 -v `pwd`/export:/export --privileged=true -p 8021:21 -p 8800:8800 $(IMAGE)

clean-export:
	rm -rf export

bash:
	$(DOCKER) run -it $(IMAGE) /bin/bash


dev:
	$(DOCKER) build --no-cache -f Dockerfile-dev -t $(IMAGE)-dev .

rundev:
	$(DOCKER) run -d -p 8080:80 -v `pwd`/../alveo-galaxy-tools:/local_tools --privileged=true -p 8021:21 -p 8800:8800 $(IMAGE)-dev

## Deployment via docker-machine - relies on private keys being available
## tested only on Openstack VM
create-machine:
	docker-machine create --driver generic \
	--generic-ip-address=$(HOST_IP_ADDRESS) \
	--generic-ssh-user centos \
	--generic-ssh-key ~/.ssh/id_rsa \
	$(DOCKER_MACHINE_NAME)

deploy:
	env DOCKER_TLS_VERIFY=1 \
	DOCKER_HOST=tcp://$(HOST_IP_ADDRESS):2376 \
	DOCKER_CERT_PATH=/Users/steve/.docker/machine/machines/galaxy-machine \
	DOCKER_MACHINE_NAME=$(DOCKER_MACHINE_NAME) \
	$(DOCKER) run -d -p 80:80 -v /mnt/export:/export --restart=always --privileged=true -p 8021:21 -p 8800:8800 --name=$(CONTAINER_NAME) $(IMAGE)

redeploy:
	env DOCKER_TLS_VERIFY=1 \
	DOCKER_HOST=tcp://$(HOST_IP_ADDRESS):2376 \
	DOCKER_CERT_PATH=/Users/steve/.docker/machine/machines/galaxy-machine \
	DOCKER_MACHINE_NAME=$(DOCKER_MACHINE_NAME) \
	$(DOCKER) stop $(CONTAINER_NAME) && \
	$(DOCKER) rm $(CONTAINER_NAME) && \
	$(DOCKER) rmi $(IMAGE) && \
	$(DOCKER) run -d -p 80:80 -v /mnt/export:/export --privileged=true --restart=always --name=$(CONTAINER_NAME) $(IMAGE)
