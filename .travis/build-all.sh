#!/bin/bash

. .travis/env.sh

echo "Building for ${ARCHS[@]}"
for a in ${ARCHS[@]}
do
	PLATFORM=${a} ./.travis/build.sh
	if [[ $? -ne 0 ]]
	then
		exit $?
	fi
done

