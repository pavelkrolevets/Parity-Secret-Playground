#!/bin/bash

declare -A loc mm mmE mmlog

green=`tput setaf 2`
reset=`tput sgr0`

# cleanup any previous attempts of running this script
docker-compose down
rm -rf parity/config/secret/db.*
rm -rf parity/config/db.*

# get up to speed
docker-compose pull ss1 alice

# setup of 3 secret nodes

for i in {1..3}
do
    # generating good config files 
    loc[$i]=parity/config/secret/ss$i.toml
    cp parity/config/secret/ss$i.bak.toml ${loc[$i]}

    # create secret accounts
    ss[$i]=$(docker run --rm -i -v $PWD/parity/config:/parity/config pavelkrolevets/parity-secert-store:fix_ss_blocking_wait --config ${loc[$i]} account new)

    # cutting the 0x 
    ssx[$i]=$(echo ${ss[$i]}|cut -d "x" -f 2)
    
    # replacing dummy variables with accounts
    sed -i '' -e  s,"accountx","${ssx[$i]}",g -e "/self_secret/s/^#//g" ${loc[$i]}

    # grabbing the enode and server public key from the log
    sslog[$i]=$(timeout 10s docker-compose up ss$i)
    ssp[$i]=$(echo "${sslog[$i]}"|grep "SecretStore node:"|cut -d "x" -f 2)
    ssE[$i]=$(echo "${sslog[$i]}"|grep "Public node URL:"|cut -d "/" -f 3)
    docker kill $(docker ps -q)
done

# setup alice bob and charlie
for i in alice bob charlie;
do
    
    #copy configs
    loc[$i]=parity/config/$i.toml
    cp parity/config/$i.bak.toml ${loc[$i]}
    
    # create accounts
    mm[$i]=$(docker run --rm -i -v $PWD/parity/config:/parity/config pavelkrolevets/parity-secert-store:beta --config ${loc[$i]} account new)

    # grep enode
    mmlog[$i]=$(timeout 10s docker-compose up $i)
    mmE[$i]=$(echo "${mmlog[$i]}"|grep "Public node URL:"|cut -d "/" -f 3)
    docker kill $(docker ps -q)

done

# replacing dummy variables with accounts, enodes and public addresses
for i in alice bob charlie 1 2 3;
do
    # accounts
    sed -i ''   -e "/validators/s/^#//g"    -e "/signer/s/^#//g" \
                -e "/account/s/^#//g"       -e "/unlock/s/^#//g" \
                -e "/bootnodes/s/^#//g"     -e "/nodes/s/^#//g" \
                -e "s,accountx,${mm[$i]},g" ${loc[$i]}
                echo $i
                echo ${loc[$i]}
    
    for j in alice bob charlie 1 2 3;
    do
        # enodes and public addresses
            sed -i '' -e "s,mmE$j,${mmE[$j]},g" -e "s,ssE$j,${ssE[$j]},g" \
                      -e s,ssp$j,${ssp[$j]},g  ${loc[$i]}

    done
done

read -p "Do you want to deploy the acl permissioning contract? (RECOMMENDED) ${green}(y/n)${reset}? " CONT
if [ "$CONT" = "y" ]; then
    
    # deploy acl
    pass=$(cat parity/config/secret/alice.pwd)
    bash acl.sh ${mm["alice"]} ${mm["bob"]} $pass

    #private contract
    read -p "Do you want to deploy the example private contract? ${green}(y/n)${reset}? " CONT
    if [ "$CONT" = "y" ]; then

        bash private.sh ${mm["alice"]} ${mm["bob"]} $pass
    else
      echo -e "${green}Setup done!${reset}"
    fi
fi