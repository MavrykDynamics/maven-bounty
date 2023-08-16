#!/bin/bash

CONTRACTS_TEST_ARRAY=()
COMMANDS=()

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
        IFS=',' read -r -a CONTRACTS_TEST_ARRAY <<< "$CONTRACTS"
    ;;
  esac
  shift
done

if [ ${#CONTRACTS_TEST_ARRAY[@]} -eq 0 ]
then
    echo "Error: You must specify at least one contract to test."
    echo "Use -h or --help to display usage."
    exit 1
fi

for contract_test in "${CONTRACTS_TEST_ARRAY[@]}"; do
    case "$contract_test" in

        bounty)
            echo "Running tests for Bounty"
            COMMANDS+=("yarn ts-mocha --paths test/01_test_bounty.spec.ts --bail --timeout 9000000")
            ;;
        cmtaToken)
            echo "Running tests for CMTA Token"
            COMMANDS+=("yarn ts-mocha --paths test/00_test_cmta_token.spec.ts --bail --timeout 9000000")
            ;;
        tokenRegistry)
            echo "Running tests for Token Registry"
            COMMANDS+=("yarn ts-mocha --paths test/01_test_token_registry.spec.ts --bail --timeout 9000000")
            ;;
        marketplace)
            echo "Running tests for marketplace"
            COMMANDS+=("yarn ts-mocha --paths test/02_test_marketplace.spec.ts --bail --timeout 9000000")
            ;;
        launchpad)
            echo "Running tests for Launchpad"
            COMMANDS+=("yarn ts-mocha --paths test/03_test_launchpad.spec.ts --bail --timeout 9000000")
            ;;
        dev)
            echo "Running tests for dev"
            COMMANDS+=("yarn ts-mocha --paths test/01_test_token_registry.spec.ts --bail --timeout 9000000")
            COMMANDS+=("yarn ts-mocha --paths test/02_test_marketplace.spec.ts --bail --timeout 9000000")
            ;;
        all)
            echo "Running all tests"
            
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