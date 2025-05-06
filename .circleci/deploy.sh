#!/bin/sh

ENVIRONMENT=$1

deploy_branch() {
  # TODO: Set up ephemeral deployment here
  helm upgrade laa-court-data-ui ./helm_deploy/. \
    --install --wait \
    --namespace=${K8S_NAMESPACE} \
    --values ./helm_deploy/values/$ENVIRONMENT.yaml \
    --set image.repository="754256621582.dkr.ecr.${ECR_REGION}.amazonaws.com/laa-assess-a-claim/laa-court-data-ui" \
    --set image.tag="branch-$CIRCLE_SHA1"
}

deploy_main() {
  helm upgrade laa-court-data-ui ./helm_deploy/. \
    --install --wait \
    --namespace=${K8S_NAMESPACE} \
    --values ./helm_deploy/values/$ENVIRONMENT.yaml \
    --set image.repository="754256621582.dkr.ecr.${ECR_REGION}.amazonaws.com/laa-assess-a-claim/laa-court-data-ui" \
    --set image.tag="main-$CIRCLE_SHA1"
}

if [[ "$CIRCLE_BRANCH" == "main" ]]; then
  deploy_main
else
  deploy_branch
fi
