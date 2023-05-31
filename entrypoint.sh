#!/bin/sh -l
set -e

if [ $# -lt 6 ]
then
  echo "Some parameters are missing"
  exit 1
fi 
VENDOR=$1
APP_ID=$2
REPOSITORY_APP_ID=$6
export KBC_DEVELOPERPORTAL_USERNAME=$3
export KBC_DEVELOPERPORTAL_PASSWORD=$4
TAG=$5

if [ "$REPOSITORY_APP_ID" = "false" ]
then
  REPOSITORY_APP_ID=$2
fi

docker pull quay.io/keboola/developer-portal-cli-v2:latest      

export TARGET_TAG=`echo $TAG | /usr/bin/pcregrep -o2 '^(refs/tags/)?(v?[0-9]+.[0-9]+.[0-9]+(-[0-9]+.[0-9]+.[0-9]+)?)$'`
if [ "$TARGET_TAG" = "" ]
then
    echo "Skipping deployment to Keboola Connection, tag ${TAG} is not allowed."
else 
	echo "Deploying '${TARGET_TAG}' to application '${APP_ID}' of vendor '${VENDOR}'. Using service account '${KBC_DEVELOPERPORTAL_USERNAME}'."
	export REPOSITORY=`docker run --rm  \
	  -e KBC_DEVELOPERPORTAL_USERNAME \
	  -e KBC_DEVELOPERPORTAL_PASSWORD \
	  quay.io/keboola/developer-portal-cli-v2:latest \
	  ecr:get-repository ${VENDOR} ${REPOSITORY_APP_ID}`

    docker run --rm \
        -e KBC_DEVELOPERPORTAL_USERNAME \
        -e KBC_DEVELOPERPORTAL_PASSWORD \
        quay.io/keboola/developer-portal-cli-v2:latest \
        update-app-repository ${VENDOR} ${APP_ID} ${TARGET_TAG} ecr ${REPOSITORY}
fi
