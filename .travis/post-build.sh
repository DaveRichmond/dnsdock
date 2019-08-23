#!/bin/bash

. .travis/env.sh

images=()
latest_images=()

docker_base=${DOCKER_USER}/dnsdock

post_file="/tmp/deploy_containers.sh"
post(){
	echo $@ >> $post_file
}

for a in ${ARCHS[@]}
do
	images=("${images[@]}" "${docker_base}:${VERSION}-${a}")
	latest_images=("${latest_images[@]}" "${docker_base}:latest-${a}")
	post docker tag ${docker_base}:${VERSION}-${a} ${docker_base}:latest-${a}
	post docker push ${docker_base}:latest-${a}
done

docker manifest create ${docker_base}:${VERSION} ${images[@]}
post docker manifest create ${docker_base}:latest ${latest_images[@]}
for a in ${ARCHS[@]}
do
	docker manifest annotate ${docker_base}:${VERSION} ${docker_base}:${VERSION}-${a} --arch ${a} --os linux
	post docker manifest annotate ${docker_base}:latest ${docker_base}:latest-${a} --arch ${a} --os linux
done

docker manifest push ${docker_base}:${VERSION}
post docker manifest push ${docker_base}:latest
