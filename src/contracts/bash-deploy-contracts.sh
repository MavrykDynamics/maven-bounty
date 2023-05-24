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