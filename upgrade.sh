#!/usr/bin/env bash

# script to upgrade an existing installation of the alveo-galaxy docker image
# based on instructions at:
# https://github.com/bgruening/docker-galaxy-stable#upgrading-images--toc

# Assumptions
# new version of stevecassidy/alveo-galaxy has been pushed to docker hub (make push)
# docker-machine is configured such that the 'docker' command operates on the remote host
#
# eval $(docker-machine env galaxy-machine)
#
# we can run commands on the remote host with ssh

REMOTE=centos@130.56.244.160
IMAGE=stevecassidy/alveo-galaxy
CONTAINER_NAME=alveo-galaxy-staging

echo "Checking SSH access to remote host."
echo "If you get a password prompt, it isn't working."
ssh ${REMOTE} sudo echo "Remote access to $REMOTE is good"
if [[ $DOCKER_HOST == '' ]]
then
    echo "DOCKER_HOST is not set - is docker-machine configured?"
    exit
else
    echo "Docker host is ${DOCKER_HOST}"
fi

read -r -p "Proceed with upgrade of Galaxy on ${DOCKER_HOST}? [y/N] " response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])+$ ]]
then
    echo "Here we go then..."
    docker pull ${IMAGE}

    docker stop ${CONTAINER_NAME}
    docker rename ${CONTAINER_NAME} ${CONTAINER_NAME}_old

    # rename the data directory
    ssh ${REMOTE} sudo mv /mnt/export /mnt/export-bak

    echo "running the new container..."
    docker run -d -p 80:80 -v /mnt/export:/export --restart=always --privileged=true -p 8021:21 -p 8800:8800 --name=${CONTAINER_NAME} ${IMAGE}

    # wait for it to complete creating export file system
    echo "Wait for /export to be created. Eg. check that the web interface is responding."
    read -r -p "Hit any key to continue: " response

    docker stop ${CONTAINER_NAME}

    echo "copying over the old database..."
    ssh ${REMOTE} sudo rm -r /mnt/export/postgresql/
    ssh ${REMOTE} sudo rsync -var /mnt/export-bak/postgresql/ /mnt/export/postgresql/
    echo "done"

    # look for changes in the config files...not implementing this since our config is made in the Dockerfile
    #
    # cd /data/galaxy-data/.distribution_config
    # for f in *; do echo $f; diff $f ../../galaxy-data-old/galaxy-central/config/$f; read; done

    echo "coping over user data..."
    ssh ${REMOTE} sudo rsync -var /mnt/export-bak/galaxy-central/database/files/* /mnt/export/galaxy-central/database/files/
    echo "done"

    # also not doing:
    # copy over installed tools (we install them in the Dockerfile)
    # copy over welcome pages and files - done in the Dockerfile)

    echo "Starting docker in interactive mode on your target host."
    echo "Run the following commands to upgrade the database"
    echo ""
    echo "startup &"
    echo "sh manage_db.sh upgrade"
    echo "exit"
    docker run -it --rm -v /mnt/export:/export ${IMAGE} /bin/bash

    # now restart the container
    docker start ${CONTAINER_NAME}

else
    echo "Aborting..."
fi


