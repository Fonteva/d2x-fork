#!/bin/bash

if [ -f ~/.dev_hub_authenticated ]; then
    exit 0
fi

if [ -z "$DEV_HUB_ALIAS" ]; then
  DEV_HUB_ALIAS="devhub"
fi

if [ -z "$DEV_HUB_AUTH_URL" ]; then
    if [ -z "$DEV_HUB_USERNAME" ]; then
        echo "DEV_HUB_USERNAME is not set. You must set either DEV_HUB_AUTH_URL or DEV_HUB_USERNAME, DEV_HUB_CLIENT_ID, and DEV_HUB_PRIVATE_KEY."
        exit 1
    fi

    if [ -z "$DEV_HUB_CLIENT_ID" ]; then
        echo "DEV_HUB_CLIENT_ID is not set. You must set either DEV_HUB_AUTH_URL or DEV_HUB_USERNAME, DEV_HUB_CLIENT_ID, and DEV_HUB_PRIVATE_KEY."
        exit 1
    fi

    if [ -z "$DEV_HUB_PRIVATE_KEY" ]; then
        echo "DEV_HUB_PRIVATE_KEY is not set. You must set either DEV_HUB_AUTH_URL or DEV_HUB_USERNAME, DEV_HUB_CLIENT_ID, and DEV_HUB_PRIVATE_KEY."
        exit 1
    fi

    echo "Authenticating to DevHub using JWT (alias $DEV_HUB_ALIAS)..."

    # Write the DEV_HUB_PRIVATE_KEY to a file
    echo $DEV_HUB_PRIVATE_KEY > /tmp/dev_hub.key

    # Authenticate to the DevHub
    sf org login jwt \
        --username $DEV_HUB_USERNAME \
        --jwt-key-file /tmp/dev_hub.key \
        --client-id $DEV_HUB_CLIENT_ID \
        --alias $DEV_HUB_ALIAS \
        --set-default-dev-hub

    [[ -f /tmp/dev_hub.key ]] && rm /tmp/dev_hub.key

else
    # Authenticate using sfdx-url
    echo "Authenticating to DevHub using sfdx-url (alias $DEV_HUB_ALIAS)..."
    echo $DEV_HUB_AUTH_URL | sf org login sfdx-url --sfdx-url-stdin --alias $DEV_HUB_ALIAS --set-default-dev-hub
fi

if [ -z "$PACKAGING_ORG_AUTH_URL" ]; then
    echo "PACKAGING_ORG_AUTH_URL not set, skipping packaging org authentication."
else
    if [ -z "$PACKAGING_ORG_ALIAS" ]; then
        PACKAGING_ORG_ALIAS="packaging"
    fi

    # Authenticate using sfdx-url
    echo "Authenticating to packaging org using sfdx-url (alias $PACKAGING_ORG_ALIAS)..."
    echo $PACKAGING_ORG_AUTH_URL | sf org login sfdx-url --sfdx-url-stdin --alias $PACKAGING_ORG_ALIAS

    # Import the org to CumulusCI
    cci org import $PACKAGING_ORG_ALIAS $PACKAGING_ORG_ALIAS
fi

if [ -z "$DEV_ORG_AUTH_URL" ]; then
    echo "DEV_ORG_AUTH_URL not set, skipping dev org authentication."
else
    if [ -z "$DEV_ORG_ALIAS" ]; then
        DEV_ORG_ALIAS="dev"
    fi

    # Authenticate using sfdx-url
    echo "Authenticating to dev org using sfdx-url (alias $DEV_ORG_ALIAS)..."
    echo $DEV_ORG_AUTH_URL | sf org login sfdx-url --sfdx-url-stdin --alias $DEV_ORG_ALIAS

    # Import the org to CumulusCI
    cci org import $DEV_ORG_ALIAS $DEV_ORG_ALIAS
fi

touch ~/.dev_hub_authenticated
