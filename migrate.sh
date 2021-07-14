#!/bin/bash

API_URL=${API_URL}
CONFIG_LOCATION="${CONFIG_LOCATION:-configs/}"
ACTIVE_PROFILE=${ACTIVE_PROFILE}
PROFILE_SEPARATOR=${PROFILE_SEPARATOR:-"-"}
DATA_KEY=${DATA_KEY:-data}
CONSUL_ROOT=${CONSUL_ROOT}
ACL_TOKEN=${ACL_TOKEN}
NO_SHARED_PROFILE=${NO_SHARED_PROFILE}

# internal usage
SHARED_FOLDER_NAME=shared
PROFILES_FOLDER_NAME=profiles
API_PREFIX=/v1/kv/

echo "API_URL:                   $API_URL"
echo "CONFIG_LOCATION:           $CONFIG_LOCATION"
echo "ACTIVE_PROFILE:            ${ACTIVE_PROFILE:-not set}"
echo "PROFILE_SEPARATOR:         $PROFILE_SEPARATOR"
echo "DATA_KEY:                  $DATA_KEY"
echo "CONSUL_ROOT:               $CONSUL_ROOT"
if [[ -z "$NO_SHARED_PROFILE" ]]; then
echo "NO_SHARED_PROFILE:         INACTIVE"
else
echo "NO_SHARED_PROFILE:         ACTIVE"
fi
if [[ -z "$ACL_TOKEN" ]]; then
echo "ACL_TOKEN:                 not set"
else
echo "ACL_TOKEN:                 *censored*"
fi

echo ""

# go to the project root
cd `dirname $0`

if [[ -z "${CONSUL_ROOT}" ]];
then
  echo "ERROR: CONSUL_ROOT variable must be set" 1>&2
  exit 1
fi

if [[ -z "${API_URL}" ]];
then
  echo "ERROR: API_URL variable must be set" 1>&2
  exit 1
fi

if [[ ! -d "${CONFIG_LOCATION}" ]];
then
  echo "ERROR: ${CONFIG_LOCATION} is not a directory" 1>&2
  exit 1
fi

# go to the configs directory
cd $CONFIG_LOCATION

if [[ $ACTIVE_PROFILE && ! -d "${ACTIVE_PROFILE}" ]];
then
  echo "ERROR: directory '${ACTIVE_PROFILE}' does not exist under CONFIG_LOCATION" 1>&2
  exit 1
fi

cd $PROFILES_FOLDER_NAME
if [[ -z $ACTIVE_PROFILE ]]; then PROFILES=`for f in */; do echo "${f%/}"; done`; else PROFILES=($ACTIVE_PROFILE); fi

for profile in $PROFILES; do
  echo "Start synchronization for profile: $profile"
  cd $profile
  for file in *; do
    folder="${file%%.*}-${profile}"
    uri="$CONSUL_ROOT$folder/$DATA_KEY"
    printf "Upload $file content to $uri ... "
    curl --request PUT --header "X-Consul-Token:$ACL_TOKEN" --data-binary @$file $API_URL$API_PREFIX$uri
    echo ""
  done
  cd ..
  echo ""
done;
cd ..

if [[ -z "$NO_SHARED_PROFILE" ]];
then
  echo "Start synchronization for the shared profile"
  cd $SHARED_FOLDER_NAME
  for file in *; do
    folder="${file%%.*}"
    uri="$CONSUL_ROOT$folder/$DATA_KEY"
    printf "Upload $file content to $uri ... "
    curl --request PUT --header "X-Consul-Token:$ACL_TOKEN" --data-binary @$file $API_URL$API_PREFIX$uri
    echo ""
  done
  cd ..
fi