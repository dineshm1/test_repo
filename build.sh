#!/usr/bin/env bash
docker images -q -f dangling=true | xargs --no-run-if-empty docker rmi
docker build -t django-docker:latest .
docker tag  django-docker:latest uzzal2k5/django-docker:latest
docker push  uzzal2k5/django-docker:latest
