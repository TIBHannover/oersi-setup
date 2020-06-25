#!/bin/bash

echo "import $@"

git clone https://gitlab.com/oersi/oersi-etl.git -b develop
cd oersi-etl
./gradlew run --args $@