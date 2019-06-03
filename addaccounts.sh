#!/usr/bin/env bash

docker exec -i -t parity-secret-playground_alice_1 /bin/parity account import parity/config/accounts/ --chain dev --keys-path /parity/config/db.alice/keys

curl --data '{"method":"personal_sendTransaction","params":[{"from":"0x00a329c0648769a73afac7f9381e08fb43dbea72","to":"0x771b286a49491f1d19d4597d5fe669936381d312","data":"0x41cd5add4fd13aedd64521e363ea279923575ff39718065d38bd46f0e6632e8e","value":"0x56BC75E2D63100000"},""],"id":1,"jsonrpc":"2.0"}' -H "Content-Type: application/json" -X POST localhost:8545
curl --data '{"method":"personal_sendTransaction","params":[{"from":"0x00a329c0648769a73afac7f9381e08fb43dbea72","to":"0xbfd086def859b8f2bf295212ecd67e55d7d17275","data":"0x41cd5add4fd13aedd64521e363ea279923575ff39718065d38bd46f0e6632e8e","value":"0x56BC75E2D63100000"},""],"id":1,"jsonrpc":"2.0"}' -H "Content-Type: application/json" -X POST localhost:8545
curl --data '{"method":"personal_sendTransaction","params":[{"from":"0x00a329c0648769a73afac7f9381e08fb43dbea72","to":"0xd407d51c75b5f8cf9366fe1f500e744fc7ad69cf","data":"0x41cd5add4fd13aedd64521e363ea279923575ff39718065d38bd46f0e6632e8e","value":"0x56BC75E2D63100000"},""],"id":1,"jsonrpc":"2.0"}' -H "Content-Type: application/json" -X POST localhost:8545
curl --data '{"method":"personal_unlockAccount","params":["0x00a329c0648769a73afac7f9381e08fb43dbea72","",null],"id":1,"jsonrpc":"2.0"}' -H "Content-Type: application/json" -X POST localhost:8545
