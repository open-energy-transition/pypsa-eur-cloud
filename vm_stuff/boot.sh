#!/bin/bash

apt install curl

apt install libcurl4-openssl-dev

curl -sSL https://get.docker.com/ | sudo sh

curl -X PUT \
    --data "true" http://metadata.google.internal/computeMetadata/v1/instance/guest-attributes/vm/ready \
    -H "Metadata-Flavor: Google"

