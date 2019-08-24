#!/bin/bash

# run with sudo!

user=tpokorra
organisation=solidcharity
image=openpetra-dev.fedora
#image=openpetra-dev.ubuntu
docker login --username $user #--password-stdin
docker tag $image $organisation/$image
docker push $organisation/$image
