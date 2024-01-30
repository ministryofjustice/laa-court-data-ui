#!/bin/sh
function _circleci_deploy() {
  usage="deploy -- deploy image from current commit to an environment
  Usage: $0 environment cluster
  Where:
    environment [dev]
    cluster [live]
  Example:
    # deploy image for current circleCI commit to dev on live cluster
    deploy.sh dev live
    "

  # exit when any command fails
  set -e
  trap 'echo command at lineno $LINENO completed with exit code $?.' EXIT

  if [[ -z "${ECR_ENDPOINT}" ]] || \
      [[ -z "${GIT_CRYPT_KEY}" ]] || \
      [[ -z "${AWS_DEFAULT_REGION}" ]] || \
      [[ -z "${GITHUB_TEAM_NAME_SLUG}" ]] || \
      [[ -z "${REPO_NAME}" ]] || \
      [[ -z "${CIRCLE_SHA1}" ]]
  then
    echo "Missing environment vars: only run this via circleCI with all relevant environment variables"
    return 1
  fi

  if [[ $# -gt 2 ]]
  then
    echo "$usage"
    return 1
  fi

  # Cloud platforms circle ci solution does not handle hyphenated names
  case "$1" in
    dev | staging | uat | production)
      environment=$1
      ;;
    *)
      echo "$usage"
      return 1
      ;;
  esac

  case "$2" in
    live | live-1)
    cluster=$2
    ;;
    *)
    echo "$usage"
    return 1
    ;;
  esac

  # apply
  printf "\e[33m--------------------------------------------------\e[0m\n"
  printf "\e[33mEnvironment: $environment\e[0m\n"
  printf "\e[33mCommit: $CIRCLE_SHA1\e[0m\n"
  printf "\e[33mBranch: $CIRCLE_BRANCH\e[0m\n"
  printf "\e[33m--------------------------------------------------\e[0m\n"
  printf '\e[33mDocker login to registry (ECR)...\e[0m\n'
  AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION} aws ecr get-login-password | docker login --username AWS --password-stdin ${ECR_ENDPOINT}

  printf '\e[33mK8S Login...\e[0m\n'
  echo -n ${K8S_CLUSTER_CERT} | base64 -d > ./ca.crt
  kubectl config set-cluster ${K8S_CLUSTER_NAME} --certificate-authority=./ca.crt --server=${K8S_CLUSTER_URL}
  kubectl config set-credentials circleci --token=${K8S_TOKEN}
  kubectl config set-context ${K8S_CLUSTER_NAME} --cluster=${K8S_CLUSTER_NAME} --user=circleci --namespace=${K8S_NAMESPACE}
  kubectl config use-context ${K8S_CLUSTER_NAME}
  kubectl --namespace=${K8S_NAMESPACE} get pods

  printf '\e[33mFormulating Image name...\e[0m\n'
  docker_image_tag=${ECR_ENDPOINT}/${GITHUB_TEAM_NAME_SLUG}/${REPO_NAME}:app-${CIRCLE_SHA1}

  # apply deployment with specfied image
  printf '\e[33mDeploying Image...\e[0m\n'
  kubectl set image -f .k8s/${cluster}/${environment}/deployment.yaml laa-court-data-ui-app=${docker_image_tag} laa-court-data-ui-metrics=${docker_image_tag} --local -o yaml | kubectl apply -f -
  kubectl set image -f .k8s/${cluster}/${environment}/deployment-worker.yaml laa-court-data-ui-worker=${docker_image_tag} laa-court-data-ui-metrics=${docker_image_tag} --local --output yaml | kubectl apply -f -

  # apply non-image specific config
  printf '\e[33mApplying Config...\e[0m\n'
  kubectl apply \
  -f .k8s/${cluster}/${environment}/service.yaml \
  -f .k8s/${cluster}/${environment}/ingress.yaml

  kubectl annotate deployments/${REPO_NAME} kubernetes.io/change-cause="$(date +%Y-%m-%dT%H:%M:%S%z) - deploying: $docker_image_tag via CircleCI"
  kubectl annotate deployments/${REPO_NAME}-worker kubernetes.io/change-cause="$(date +%Y-%m-%dT%H:%M:%S%z) - deploying: $docker_image_tag via CircleCI"

  # wait for rollout to succeed or fail/timeout
  kubectl rollout status deployments/${REPO_NAME}
  kubectl rollout status deployments/${REPO_NAME}-worker
}

_circleci_deploy $@
