#!/bin/bash

function usage
{
	echo "$0 {TAG} {WORK_DIR} {GIT_USER_NAME} {GIT_EMAIL} {TIZEN_SSH_USER_ID} {TIZEN_SSH_EMAIL}"
	echo "$0 ubuntu_tizen . 'Sung-Jin Park' input.hacker@gmail.com sj76park sj76.park@samsung.com"
	exit
}

echo "user=${USER}, home=${HOME}"

if [ "$1" = "" ]; then
	usage
fi

TAG="$1"
if [ "$TAG" = "" ]; then
	TAG="ubuntu_tizen"
fi

WORK_DIR="$2"
if [ "$WORK_DIR" = "" ]; then
	WORK_DIR="."
fi

GIT_USER_NAME="$3"
if [ "$GIT_USER_NAME" = "" ]; then
	usage
fi

GIT_EMAIL="$4"
if [ "$GIT_EMAIL" = "" ]; then
	usage
fi

TIZEN_SSH_USER_ID="$5"
if [ "$TIZEN_SSH_USER_ID" = "" ]; then
	usage
fi

TIZEN_SSH_EMAIL="$6"
if [ "$TIZEN_SSH_EMAIL" = "" ]; then
	usage
fi

cp -af ${HOME}/.ssh .

#use of cache
docker build --build-arg GIT_USER_NAME="${GIT_USER_NAME}" --build-arg GIT_EMAIL="${GIT_EMAIL}" --build-arg TIZEN_SSH_USER_ID="${TIZEN_SSH_USER_ID}" --build-arg TIZEN_SSH_EMAIL="${TIZEN_SSH_EMAIL}"  --build-arg http_proxy=$http_proxy --build-arg https_proxy=$https_proxy --build-arg USER=$USER --build-arg UID=$UID --build-arg SHELL=$SHELL --build-arg HOME_DIR="${HOME}" --no-cache=false -t ${TAG} ${WORK_DIR}

#no use of cache
#docker build --build-arg GIT_USER_NAME="${GIT_USER_NAME}" --build-arg GIT_EMAIL="${GIT_EMAIL}" --build-arg TIZEN_SSH_USER_ID="${TIZEN_SSH_USER_ID}" --build-arg TIZEN_SSH_EMAIL="${TIZEN_SSH_EMAIL}"  --build-arg http_proxy=$http_proxy --build-arg https_proxy=$https_proxy --build-arg USER=$USER --build-arg UID=$UID --build-arg SHELL=$SHELL --build-arg HOME_DIR="${HOME}" --no-cache=true -t ${TAG} ${WORK_DIR}

rm -rf .ssh
