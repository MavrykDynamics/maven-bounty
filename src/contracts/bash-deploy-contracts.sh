#!/bin/bash

CONTRACTS_DEPLOY_ARRAY=()
COMMANDS=()
DEPLOYMENT_FILE=./test/contractDeployments.json

# Parse arguments
# if [ $# -eq 0 ]
# then
#     help
# fi
while [ $# -gt 0 ] ; do
  case $1 in
    -h | --help)
        help
    ;;
    -c | --contracts)
        CONTRACTS=$2
        IFS=',' read -r -a CONTRACTS_DEPLOY_ARRAY <<< "$CONTRACTS"
    ;;
  esac
  shift
done

if [ ${#CONTRACTS_DEPLOY_ARRAY[@]} -eq 0 ]
then
    echo "Error: You must specify at least one contract to deploy."
    echo "Use -h or --help to display usage."
    exit 1
fi

if [ ! -f $DEPLOYMENT_FILE ]
then
    echo '{}' > $DEPLOYMENT_FILE
fi

for contract_test in "${CONTRACTS_DEPLOY_ARRAY[@]}"; do
    case "$contract_test" in
        cmtaToken)
            echo "Deploying CMTA Token"
            COMMANDS+=("yarn ts-mocha --paths test/deploy/01_deploy_cmta_token.spec.ts --bail --timeout 9000000")
            ;;
        freezeRuleEngine)
            echo "Deploying Freeze Rule Engine"
            COMMANDS+=("yarn ts-mocha --paths test/deploy/02_deploy_freeze_rule_engine.spec.ts --bail --timeout 9000000")
            ;;
        mockTokens)
            echo "Deploying Mock Tokens"
            COMMANDS+=("yarn ts-mocha --paths test/deploy/03_deploy_mock_tokens.spec.ts --bail --timeout 9000000")
            ;;
        tokenRegistry)
            echo "Deploying Token Registry"
            COMMANDS+=("yarn ts-mocha --paths test/deploy/04_deploy_token_registry.spec.ts --bail --timeout 9000000")
            ;;
        marketplace)
            echo "Deploying Marketplace"
            COMMANDS+=("yarn ts-mocha --paths test/deploy/05_deploy_marketplace.spec.ts --bail --timeout 9000000")
            ;;
        launchpad)
            echo "Deploying Launchpad"
            COMMANDS+=("yarn ts-mocha --paths test/deploy/06_deploy_launchpad.spec.ts --bail --timeout 9000000")
            ;;
        all)
            echo "Deploy all contracts"

            ;;
        *)
            echo "Unknown contract test: $contract_test"
            ;;
    esac
done

for cmd in "${COMMANDS[@]}"; do
    echo "Executing command: $cmd"
    eval $cmd
done