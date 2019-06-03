# Parity Secret Store playground (working non blocking secret store)

We really appreciated the ease with which one could set up a [POA network](https://github.com/orbita-center/parity-poa-playground), and decided to build on top of it SecretStore support as the Parity tutorials seemed to be oriented more towards DevOps rather than blockchain developers.

This repository creates all the node configurations required to perform secret transactions on a Parity network.

Run: 
   1. `bash setup.sh` It will create containers with secret store and clients, then stop them.
   2. `docker-compose up -d` to start created containers with confis.

The current version follows the Parity tutorials for SecretStore and Private transactions:

https://wiki.parity.io/Secret-Store-Tutorial-overview

https://wiki.parity.io/Private-Transactions.html

As a result, one can directly start sending private transactions, without the need of manually configuring the network. All accounts are generated on setup script execution, no accounts pre-exist.

We strongly recommended going through the tutorials to understand what the setup does and how to interact with the SecretStore.

Currently, we support the InstantSeal network and will implement POA as soon as I have some more time.

Requirements:

Linux:

jq: `sudo apt-get install jq`

Mac OS:

[Upgrade your bash to >= 4.0](https://akrabat.com/upgrading-to-bash-4-on-macos/) because the setup script uses bash associative arrays.

Jq and Timeout:
```
brew install jq coreutils
sudo ln -s /usr/local/bin/gtimeout /usr/local/bin/timeout
```
