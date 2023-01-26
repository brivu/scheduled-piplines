#!/bin/bash
ORB_EVAL_PROJECT_NAME=$(eval echo "${ORB_EVAL_PROJECT_NAME}")
ORB_EVAL_SCHEDULE_JSON_PATH=$(eval echo "${ORB_EVAL_SCHEDULE_JSON_PATH}")
URL="https://circleci.com/api/v2/project/${ORB_VAL_VCS_TYPE}/${ORB_VAL_NAMESPACE}/${ORB_EVAL_PROJECT_NAME}/schedule"
DATA=$(jq '.' -c "${ORB_EVAL_SCHEDULE_JSON_PATH}")
SCHEDULE_NAME=$(jq '.name' "${ORB_EVAL_SCHEDULE_JSON_PATH}")

curl --request GET \
  --url "${URL}" \
  --header "Circle-Token: $CIRCLE_TOKEN" > all_schedules.json

if jq ".items[] | .name" all_schedules.json | grep "${SCHEDULE_NAME}"; then
        SCHEDULE_ID=$(jq -r '.items[] | select( .name == '"${SCHEDULE_NAME}"') | .id' all_schedules.json)
        echo "The ID is ${SCHEDULE_ID}"
        set -x
        curl --request PATCH \
            --url https://circleci.com/api/v2/schedule/"${SCHEDULE_ID}" \
            --header "Circle-Token: ${CIRCLE_TOKEN}" \
            --header 'content-type: application/json' \
            --data "${DATA}"
        set +x
else
        set -x
        curl --request POST \
            --url "${URL}" \
            --header "Circle-Token: ${CIRCLE_TOKEN}" \
            --header 'content-type: application/json' \
            --data "${DATA}"
        set +x
fi