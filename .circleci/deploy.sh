#!/bin/sh

ENVIRONMENT=$1

# Convert the branch name into a string that can be turned into a valid URL
BRANCH_RELEASE_NAME=$(echo $CIRCLE_BRANCH | tr '[:upper:]' '[:lower:]' | sed 's:^\w*\/::' | tr -s ' _/[]().' '-' | cut -c1-18 | sed 's/-$//')

deploy_branch() {
  # Set the deployment host, this will add the prefix of the branch name e.g crm457-1062-tempor
  RELEASE_HOST="$BRANCH_RELEASE_NAME.view-court-data.cloud-platform.service.justice.gov.uk"
  # Set the ingress name, needs release name, namespace and -green suffix
  IDENTIFIER="$BRANCH_RELEASE_NAME-laa-court-data-ui-dev-green"

  helm upgrade $BRANCH_RELEASE_NAME ./helm_deploy/. \
    --install --wait \
    --namespace=${K8S_NAMESPACE} \
    --values ./helm_deploy/values/$ENVIRONMENT.yaml \
    --set image.repository="754256621582.dkr.ecr.${ECR_REGION}.amazonaws.com/laa-assess-a-claim/laa-court-data-ui" \
    --set image.tag="branch-$CIRCLE_SHA1" \
    --set identifier="$IDENTIFIER" \
    --set host="$RELEASE_HOST" \
    --set nameOverride="$BRANCH_RELEASE_NAME"\
    --set fullnameOverride="$BRANCH_RELEASE_NAME"\
    --set branch=true
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
  if [ $? -eq 0 ]; then
    echo "Deploy succeeded"
  else
    # If a previous `helm upgrade` was cancelled this could have got the release stuck in
    # a "pending-upgrade" state (c.f. https://stackoverflow.com/a/65135726). If so, this
    # can generally be fixed with a `helm rollback`, so we try that here.
    echo "Deploy failed. Attempting rollback"
    helm rollback $BRANCH_RELEASE_NAME
    if [ $? -eq 0 ]; then
      echo "Rollback succeeded. Retrying deploy"
      deploy_branch
    else
      echo "Rollback failed. Consider manually running 'helm delete $BRANCH_RELEASE_NAME'"
      exit 1
    fi
fi
