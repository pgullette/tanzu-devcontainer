#!/usr/bin/env sh
# printenv > ~/env.out
# ls -ltr /vscode/vscode-server/bin/linux-x64
DEVCONTAINER_WORKSPACE=/workspaces/tanzu-devcontainer/.devcontainer

# Change to post-start dir
cd $DEVCONTAINER_WORKSPACE/post-start

# TODO: add logic to check mounted volume to see if a token already exists

# Log in to customer org via OIDC
tanzu login

# Get the needed data into variables
CONTEXT_NAME=$(tanzu context list --wide | grep $TANZU_CLI_CLOUD_SERVICES_ORGANIZATION_ID | awk '{print $1}')
ACCESS_TOKEN=$(tanzu context get $CONTEXT_NAME | yq '.globalOpts.auth.accessToken')
ID_TOKEN=$(tanzu context get $CONTEXT_NAME | yq '.globalOpts.auth.IDToken')

# Create templated token request
jq -r --arg orgId "$TANZU_CLI_CLOUD_SERVICES_ORGANIZATION_ID" --arg idToken "$ID_TOKEN" '.orgId=$orgId | .idToken=$idToken' sample-token-request.json > token-request.json

# Generate and store a tmc service member token
export TANZU_API_TOKEN=$(curl -s -X POST -H 'Accept: application/json' -H "Authorization: Bearer $ACCESS_TOKEN" -H 'Content-Type: application/json' \
                            -d @token-request.json  https://console.cloud.vmware.com/csp/gateway/am/api/loggedin/user/api-tokens \
                            | jq -r '.apiToken')

# Create the tanzu context using the tmc-token
tanzu tmc context create tmc-member -e $TMC_ENDPOINT