#!/bin/bash

COMMAND=$1

mv pypsa-eur/* /tmp/

cp -Rf config/* /tmp/config/

cd tmp

eval $COMMAND

cd ..

cp -Rf tmp/results/* /results/
