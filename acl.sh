#!/bin/bash

alice=$1
bob=$2
PASSWORD=$3
DOC=$(echo mySecretDocument | sha256sum| awk '{ print $1 }')

green=`tput setaf 2`
reset=`tput sgr0`

#cp "contracts/pangu_grantPermission.sol" "contracts/contract.sol"

#sed -i '' -e s,alicer,$alice,g -e s,bobr,$bob,g /contracts/pangu_grantPermission.sol

# Compile acl contract

docker run -v $PWD/contracts:/solidity ethereum/solc:0.5.3 --bin -o . pangu_grantPermission.sol --overwrite

docker-compose up -d alice bob charlie ss1 ss2 ss3
sleep 10

printf "Generating Secret Store key\n"

RES=$(curl -s --data-binary '{"jsonrpc": "2.0", "method": "secretstore_signRawHash", "params": ["'$alice'", "'$PASSWORD'", "'0x$DOC'"], "id":1 }' -H 'content-type: application/json' localhost:8545 |jq .result| tr -d '"'|cut -d "x" -f 2)

sleep 2

SSSKEY=$(curl -s -X POST http://localhost:8010/shadow/$DOC/$RES/1)

echo "$SSSKEY">SSSkey.txt

sleep 3

bytecode="0x$(cat contracts/SSPermissions.bin)"

printf "Compose contract create\n"

COMPOSE=$(curl -s --data '{"method":"parity_composeTransaction","params":[{"from":"'$alice'", "data":"'$bytecode'"}],"id":1,"jsonrpc":"2.0"}' -H "Content-Type: application/json" -X POST localhost:8545| jq .result)
GAS=$(echo $COMPOSE | jq .gas)
NONCE=$(echo $COMPOSE | jq .nonce)

sleep 2

printf  "Sign contract\n"

SIGNED=$(curl -s --data '{"method":"personal_signTransaction","params":[{"condition":null,"data":"'$bytecode'","from":"'$alice'","gas":'$GAS',"gasPrice":"0x0","nonce":'$NONCE',"to":null,"value":"0x0"},"'$PASSWORD'"],"id":1,"jsonrpc":"2.0"}' -H "Content-Type: application/json" -X POST localhost:8545 | jq .result)
CONTRACTRAW=$(echo $SIGNED | jq .raw)

sleep 2

printf "Sending contract: \n"
RESULT=$(curl -s --data '{"method":"eth_sendRawTransaction","params":['$CONTRACTRAW'],"id":1,"jsonrpc":"2.0"}' -H "Content-Type: application/json" -X POST localhost:8545|jq .result)
echo -e "${green}$RESULT${reset}"

sleep 2

ADDRESS=$(curl -s --data '{"method":"eth_getTransactionReceipt","params":['$RESULT'],"id":1,"jsonrpc":"2.0"}' -H "Content-Type: application/json" -X POST localhost:8545|jq '.result .contractAddress')

# cut x again

ADDRESSx=$(echo $ADDRESS|cut -d "x" -f 2)

# insert contract address in ss nodes

docker kill $(docker ps -q)

sed -i '' -e  's,acl_contract = "none",acl_contract = "'$ADDRESSx',g' parity/config/secret/ss1.toml parity/config/secret/ss2.toml parity/config/secret/ss3.toml

echo -e "${green}ACL deployed${reset}"