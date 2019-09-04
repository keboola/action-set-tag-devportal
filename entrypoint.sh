#!/bin/sh -l
set -e

if [ $# -lt 5 ]
then
  echo "Some parameters are missing"
  exit 1
fi 
VENDOR=$1
APP_ID=$2
export KBC_DEVELOPERPORTAL_USERNAME=$3
export KBC_DEVELOPERPORTAL_PASSWORD=$4
TAG=$5

docker pull quay.io/keboola/developer-portal-cli-v2:latest      

export TARGET_TAG=`echo $TAG | /usr/bin/pcregrep -o1 '^refs/tags/(v?[0-9]+.[0-9]+.[0-9]+)$'`
if [ "$TARGET_TAG" = "" ]
    echo "Skipping deployment to Keboola Connection, tag ${TARGET_TAG} is not allowed."
else 
	echo "Deploying '${TARGET_TAG}' to application '${APP_ID}' of vendor '${VENDOR}'. Using service account '${KBC_DEVELOPERPORTAL_USERNAME}'."
	export REPOSITORY=`docker run --rm  \
	  -e KBC_DEVELOPERPORTAL_USERNAME \
	  -e KBC_DEVELOPERPORTAL_PASSWORD \
	  quay.io/keboola/developer-portal-cli-v2:latest \
	  ecr:get-repository ${VENDOR} ${APP_ID}`

    docker run --rm \
        -e KBC_DEVELOPERPORTAL_USERNAME \
        -e KBC_DEVELOPERPORTAL_PASSWORD \
        quay.io/keboola/developer-portal-cli-v2:latest \
        update-app-repository ${VENDOR} ${APP_ID} ${TARGET_TAG} ecr ${REPOSITORY}
fi
