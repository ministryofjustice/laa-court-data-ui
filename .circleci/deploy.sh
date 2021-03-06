#!/bin/sh
function _circleci_deploy() {
  usage="deploy -- deploy image from current commit to an environment
  Usage: $0 environment
  Where:
    environment [dev]
  Example:
    # deploy image for current circleCI commit to dev
    deploy.sh dev
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

  if [[ $# -gt 1 ]]
  then
    echo "$usage"
    return 1
  fi

  # Cloud platforms circle ci solution does not handle hyphenated names
  case "$1" in
    dev | staging | uat | production)
      environment=$1
      cp_context=$environment
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
  aws ecr get-login-password --region ${AWS_DEFAULT_REGION} | docker login --username AWS --password-stdin ${ECR_ENDPOINT}
  setup-kube-auth
  kubectl config use-context ${cp_context}

  docker_image_tag=${ECR_ENDPOINT}/${GITHUB_TEAM_NAME_SLUG}/${REPO_NAME}:app-${CIRCLE_SHA1}

  # decrypt and apply secrets first so changes can be picked up by deployment
  echo "${GIT_CRYPT_KEY}" | base64 -d > git-crypt.key
  git-crypt unlock git-crypt.key
  kubectl apply -f .k8s/${environment}/secrets.yaml 2> /dev/null

  # apply deployment with specfied image
  kubectl set image -f .k8s/${environment}/deployment.yaml laa-court-data-ui-app=${docker_image_tag} laa-court-data-ui-metrics=${docker_image_tag} --local -o yaml | kubectl apply -f -
  kubectl set image -f .k8s/${environment}/deployment-worker.yaml laa-court-data-ui-worker=${docker_image_tag} laa-court-data-ui-metrics=${docker_image_tag} --local --output yaml | kubectl apply -f -

  # apply non-image specific config
  kubectl apply \
  -f .k8s/${environment}/service.yaml \
  -f .k8s/${environment}/ingress.yaml

  kubectl annotate deployments/${REPO_NAME} kubernetes.io/change-cause="$(date +%Y-%m-%dT%H:%M:%S%z) - deploying: $docker_image_tag via CircleCI"
  kubectl annotate deployments/${REPO_NAME}-worker kubernetes.io/change-cause="$(date +%Y-%m-%dT%H:%M:%S%z) - deploying: $docker_image_tag via CircleCI"

  # wait for rollout to succeed or fail/timeout
  kubectl rollout status deployments/${REPO_NAME}
  kubectl rollout status deployments/${REPO_NAME}-worker
}

_circleci_deploy $@
