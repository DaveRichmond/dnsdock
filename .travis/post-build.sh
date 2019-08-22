#!/bin/bash

. .travis/env.sh

images=()
latest_images=()

docker_base=${DOCKER_USER}/dnsdock

for a in ${ARCHS[@]}
do
	images=("${images[@]}" "${docker_base}:${VERSION}-${a}")
	latest_images=("${latest_images[@]}" "${docker_base}:latest-${a}")
	docker tag ${docker_base}:${VERSION}-${a} ${docker_base}:latest-${a}
done

docker manifest create ${docker_base}:${VERSION} ${images[@]}
docker manifest create ${docker_base}:latest ${latest_images[@]}
docker tag ${docker_base}:${VERSION} ${docker_base}:latest
for a in ${ARCHS[@]}
do
	docker manifest annotate ${docker_base}:${VERSION} ${docker_base}:${VERSION}-${a} --arch ${a}
	docker manifest annotate ${docker_base}:latest ${docker_base}:latest-${a} --arch ${a}
	echo "docker push ${docker_base}:latest-${a}" >> /tmp/deploy_containers.sh
done

docker push ${docker_base}:${VERSION}
echo "docker push ${docker_base}:latest" >> /tmp/deploy_containers.sh
