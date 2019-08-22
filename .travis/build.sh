#!/bin/bash

PLATFORM=${PLATFORM:-amd64}
USER=${DOCKER_USER:-aacebedo}
IMAGE=${IMAGE:-dnsdock}

case $PLATFORM in
	arm64v8) DOCKER_PLATFORM=arm64 ;;
	arm32v6) DOCKER_PLATFORM=arm ;;
	*) DOCKER_PLATFORM=${PLATFORM} ;;
esac

echo "Building image for ${PLATFORM} (${DOCKER_PLATFORM})"

if git describe --contains ${TRAVIS_COMMIT} &>/dev/null
then
	VERSION=git describe --contains ${TRAVIS_COMMIT}
else
	VERSION="dev"
fi
buildctl build --frontend dockerfile.v0 \
        --opt platform=linux/${DOCKER_PLATFORM} \
        --output type=image,name="docker.io/${USER}/${IMAGE}:${VERSION}-${PLATFORM}",push=true \
        --local dockerfile=. \
        --local context=.
if [[ $? -ne 0 ]]
then
	exit $?
fi

docker_image=${IMAGE}-${VERSION}-${PLATFORM}

docker rm -f ${docker_image} # somehow we had one left over *shrugs*, lets cleanup before we continue

docker run --name ${docker_image} ${USER}/${IMAGE}:${VERSION}-${PLATFORM}
docker cp ${docker_image}:/bin/dnsdock /build/dnsdock.${PLATFORM}
docker stop ${docker_image}
docker rm ${docker_image}

