#!/bin/sh
function _deploy() {
  usage="deploy -- deploy image from current commit to an environment
  Usage: .k8s/scripts/deploy environment [image-tag]
  Where:
    environment [dev]
    [image_tag] any valid ECR image tag for app
  Example:
    # deploy image for current commit to dev
    deploy.sh dev

    # deploy latest image of master to dev
    deploy.sh dev latest

    # deploy latest branch image to dev
    deploy.sh dev <branch-name>-latest

    # deploy specific image (based on commit sha)
    deploy.sh dev <commit-sha>
    "

  # exit when any command fails, keep track of the last for output
  # https://intoli.com/blog/exit-on-errors-in-bash-scripts/
  set -e
  trap 'last_command=$current_command; current_command=$BASH_COMMAND' DEBUG
  trap 'echo "\"${last_command}\" command completed with exit code $?."' EXIT

  if [ $# -gt 2 ]
  then
    echo "$usage"
    return 0
  fi

  case "$1" in
    dev | staging | uat | production)
      environment=$1
      ;;
    *)
      echo "$usage"
      return 0
      ;;
  esac

  if [ -z "$2" ]
  then
    current_branch=$(git branch | grep \* | cut -d ' ' -f2)
    current_version=$(git rev-parse $current_branch)
  else
    current_version=$2
  fi

  context='live-1'
  component=app
  team_name=laa-get-paid
  repo_name=laa-court-data-ui
  docker_endpoint=754256621582.dkr.ecr.eu-west-2.amazonaws.com
  docker_registry=${docker_endpoint}/${team_name}/${repo_name}
  docker_image_tag=${docker_registry}:${component}-${current_version}

  kubectl config set-context ${context} --namespace=${repo_name}-${environment}
  kubectl config use-context ${context}

  printf "\e[33m--------------------------------------------------\e[0m\n"
  printf "\e[33mContext: $context\e[0m\n"
  printf "\e[33mEnvironment: $environment\e[0m\n"
  printf "\e[33mDocker image: $docker_image_tag\e[0m\n"
  printf "\e[33m--------------------------------------------------\e[0m\n"

  # TODO: check if image exists and if not offer to build or abort

  # apply secrets first so changes can be picked up by deployment
  kubectl apply -f .k8s/${environment}/secrets.yaml

  # apply deployment with specfied image
  kubectl set image -f .k8s/${environment}/deployment.yaml ${repo_name}-app=${docker_image_tag} --local --output yaml | kubectl apply -f -
  kubectl set image -f .k8s/${environment}/deployment-worker.yaml ${repo_name}-worker=${docker_image_tag} ${repo_name}-metrics=${docker_image_tag} --local --output yaml | kubectl apply -f -

  # apply non-image specific config
  kubectl apply \
    -f .k8s/${environment}/service.yaml \
    -f .k8s/${environment}/ingress.yaml

  kubectl annotate deployments/${repo_name} kubernetes.io/change-cause="$(date) - deploying: $docker_image_tag via local machine"
  kubectl annotate deployments/${repo_name}-worker kubernetes.io/change-cause="$(date) - deploying: $docker_image_tag via local machine"

  # Forcibly restart the app regardless of whether
  # there are changes to apply new secrets, at least.
  # - requires kubectl verion 1.15+
  #
  kubectl rollout restart deployments/${repo_name}
  kubectl rollout restart deployments/${repo_name}-worker

  # wait for rollout to succeed or fail/timeout
  kubectl rollout status deployments/${repo_name} --timeout=600s
  kubectl rollout status deployments/${repo_name}-worker --timeout=600s
}

_deploy $@
