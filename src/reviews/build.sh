#!/usr/bin/env bash

#java build the app.
docker run --rm -v `pwd`:/usr/bin/app:rw niaquinto/gradle clean build
pushd reviews-wlpcfg
#with ratings black stars
docker build -t istio/examples-bookinfo-reviews-v2:${VERSION} --build-arg service_version=v2 --build-arg enable_ratings=true .
popd
