#!/bin/sh

ENVIRONMENT=$1

helm upgrade laa-court-data-ui ./helm_deploy/. \
  --install --wait \
  --namespace=${K8S_NAMESPACE} \
  --values ./helm_deploy/values/$ENVIRONMENT.yaml \
  --set image.repository="754256621582.dkr.ecr.${ECR_REGION}.amazonaws.com/${ECR_REPOSITORY}" \
  --set image.tag="main-$CIRCLE_SHA1"
