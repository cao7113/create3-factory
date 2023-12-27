#!/bin/bash

deploy() {
	NETWORK=$1

	# RAW_RETURN_DATA=$(forge script script/Deploy.s.sol -f $NETWORK -vvvv --json --silent --broadcast --verify --skip-simulation --legacy)
	# without --verify
	RAW_RETURN_DATA=$(forge script script/Deploy.s.sol -f $NETWORK -vvvv --json --silent --broadcast --skip-simulation --legacy)
	echo $RAW_RETURN_DATA | jq
	RETURN_DATA=$(echo $RAW_RETURN_DATA | jq -r '.returns' 2> /dev/null)

	factory=$(echo $RETURN_DATA | jq -r '.factory.value')
	lower_factory=$(echo "$factory" | tr '[:upper:]' '[:lower:]')

	saveContract $NETWORK CREATE3Factory $lower_factory
}

saveContract() {
	NETWORK=$1
	CONTRACT=$2
	ADDRESS=$3

	ADDRESSES_FILE=./deployments/$NETWORK.json

	# create an empty json if it does not exist
	if [[ ! -e $ADDRESSES_FILE ]]; then
		echo "{}" >"$ADDRESSES_FILE"
	fi
	result=$(cat "$ADDRESSES_FILE" | jq -r ". + {\"$CONTRACT\": \"$ADDRESS\"}")
	printf %s "$result" >"$ADDRESSES_FILE"
}

deploy $1
