
DOCKER=docker
IMAGE=stevecassidy/alveo-galaxy

latest:
	$(DOCKER) build -f Dockerfile -t $(IMAGE) .

no-cache:
	$(DOCKER) build --no-cache -f Dockerfile -t $(IMAGE) .

push:
	$(DOCKER) push $(IMAGE)

tag:
	if [ -n "$(TAG)" ] ; then $(DOCKER) tag $(IMAGE) $(IMAGE):$(TAG) ; fi

run:
	$(DOCKER) run -d -p 8080:80  $(IMAGE)

run-export:
	mkdir -p export
	$(DOCKER) run -d -p 8080:80 -v `pwd`/export:/export $(IMAGE)

clean-export:
	rm -rf export

bash:
	$(DOCKER) run -it $(IMAGE) /bin/bash
