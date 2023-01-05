#!/bin/sh
#
# Build Docker images.
# ------------------------------------------------------------------------------

if grep -qw docker /tmp/prov
  then if [ -s "$DOCKER_COMPOSE_CNF" ]
    then cd "$(dirname "$DOCKER_COMPOSE_CNF")" || exit
    echo 'Creating Docker environment'
    docker-compose up -d 2>/dev/null
    cd "$DUD" || exit
  elif [ -e "$DOCKER_CNF" ]
    then cd "$(dirname "$DOCKER_CNF")" || exit
    echo 'Creating Docker image'
    docker run -d "$(docker build -q .)" >/dev/null
    cd "$DUD" || exit
  fi
fi
