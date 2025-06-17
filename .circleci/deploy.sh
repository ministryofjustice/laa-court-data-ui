#!/bin/sh

ENVIRONMENT=$1
PINGDOM_IPS=$(curl -s https://my.pingdom.com/probes/ipv4 | tr -d ' ' | tr '\n' ',' | sed 's/,/\\,/g' | sed 's/\\,$//')
VPN_IPS=$(curl -s https://raw.githubusercontent.com/ministryofjustice/laa-ip-allowlist/main/cidrs.txt | tr -d ' ' | tr '\n' ',' | sed 's/,/\\,/g' | sed 's/\\,$//')

# Convert the branch name into a string that can be turned into a valid URL
BRANCH_RELEASE_NAME=$(echo $CIRCLE_BRANCH | tr '[:upper:]' '[:lower:]' | sed 's:^\w*\/::' | tr -s ' _/[]().' '-' | cut -c1-18 | sed 's/-$//')

deploy_branch() {
  # Set the deployment host, this will add the prefix of the branch name
  RELEASE_HOST="$BRANCH_RELEASE_NAME-vcd.apps.live.cloud-platform.service.justice.gov.uk"
  # The identifier is of format <ingress name>-<namespace>-green
  IDENTIFIER="$BRANCH_RELEASE_NAME-app-ingress-laa-court-data-ui-dev-green"

  helm upgrade $BRANCH_RELEASE_NAME ./helm_deploy/. \
    --install --wait \
    --namespace=${K8S_NAMESPACE} \
    --values ./helm_deploy/values/$ENVIRONMENT.yaml \
    --set image.repository="754256621582.dkr.ecr.${ECR_REGION}.amazonaws.com/laa-assess-a-claim/laa-court-data-ui" \
    --set image.tag="$TAG" \
    --set identifier="$IDENTIFIER" \
    --set host="$RELEASE_HOST" \
    --set nameOverride="$BRANCH_RELEASE_NAME"\
    --set fullnameOverride="$BRANCH_RELEASE_NAME"\
    --set-string pingdomIps="$PINGDOM_IPS" \
    --set-string vpnIps="$VPN_IPS" \
    --set replicas.web=1\
    --set branch=true

  echo "DEPLOYED TO: $RELEASE_HOST"
}

deploy_main() {
  helm upgrade laa-court-data-ui ./helm_deploy/. \
    --install --wait \
    --namespace=${K8S_NAMESPACE} \
    --values ./helm_deploy/values/$ENVIRONMENT.yaml \
    --set-string pingdomIps="$PINGDOM_IPS" \
    --set-string vpnIps="$VPN_IPS" \
    --set image.repository="754256621582.dkr.ecr.${ECR_REGION}.amazonaws.com/laa-assess-a-claim/laa-court-data-ui" \
    --set image.tag="$TAG"
}

if [[ "$CIRCLE_BRANCH" == "main" ]]; then
  TAG="main-$CIRCLE_SHA1"
  deploy_main
else
  TAG="branch-$CIRCLE_SHA1"
  if [[ "$K8S_NAMESPACE" == "laa-court-data-ui-dev" ]]; then
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
  else
    deploy_main
  fi
fi
