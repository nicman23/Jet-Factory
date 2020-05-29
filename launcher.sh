#!/bin/bash
# This script launch docker to build android or linux

echo "Type the path to a folder you want to use as storage"
echo "can be a mounted external HDD"

echo "Press enter..."
read basepath

if [ ! -d $basepath ] 
then
    echo "Directory $basepath DOES NOT exists. Exiting." 
    exit 1
fi

ARCH1="arch"
ARCH2="blackarch"
ARCH3="arch-bang"
FEDORA="fedora"
GENTOO="gentoo"
UBUNTU="ubuntu"
LINEAGE="lineage (defaults to icosa)"
ICOSA="icosa"
FOSTER="foster"
FOSTER_TAB="foster_tab"

select distro in "$ARCH1" "$ARCH2" "$ARCH3" "$FEDORA" "$GENTOO" "$UBUNTU" "$LINEAGE" "$ICOSA" "$FOSTER" "$FOSTER_TAB"
do
    docker build -t alizkan/jet-factory:1.0.0 .
    case $distro in
        $ARCH1)
            echo -e "\nBuilding $ARCH1"
            docker run --security-opt apparmor:unconfined --cap-add SYS_ADMIN --privileged --rm -it -e DISTRO="$ARCH1" -v /dev:/dev -v "$basepath":/root/${distro} -v /var/run/docker.sock:/var/run/docker.sock alizkan/jet-factory:1.0.0
            exit 0
        ;;
        $ARCH2)
            echo -e "\nBuilding $ARCH2"
            docker run --security-opt apparmor:unconfined --cap-add SYS_ADMIN --privileged --rm -it -e DISTRO="$ARCH2" -v /dev:/dev -v "$basepath":/root/${distro} -v /var/run/docker.sock:/var/run/docker.sock alizkan/jet-factory:1.0.0
            exit 0
        ;;
        $ARCH3)
            echo -e "\nBuilding $ARCH3"
            docker run --security-opt apparmor:unconfined --cap-add SYS_ADMIN --privileged --rm -it -e DISTRO="$ARCH3" -v /dev:/dev -v "$basepath":/root/${distro} -v /var/run/docker.sock:/var/run/docker.sock alizkan/jet-factory:1.0.0
            exit 0
        ;;
        $FEDORA)
            echo -e "\nBuilding $FEDORA"
            docker run --security-opt apparmor:unconfined --cap-add SYS_ADMIN --privileged --rm -it -e DISTRO="$FEDORA" -v /dev:/dev -v "$basepath":/root/${distro} -v /var/run/docker.sock:/var/run/docker.sock alizkan/jet-factory:1.0.0
            exit 0
        ;;
        $GENTOO)
            echo -e "\nBuilding $GENTOO"
            docker run --security-opt apparmor:unconfined --cap-add SYS_ADMIN --privileged --rm -it -e DISTRO="$GENTOO" -v /dev:/dev -v "$basepath":/root/${distro} -v /var/run/docker.sock:/var/run/docker.sock alizkan/jet-factory:1.0.0
            exit 0
        ;;
        $UBUNTU)
            echo -e "\nBuilding $UBUNTU"
            docker run --security-opt apparmor:unconfined --cap-add SYS_ADMIN --privileged --rm -it -e DISTRO="$UBUNTU" -v /dev:/dev -v "$basepath":/root/${distro} -v /var/run/docker.sock:/var/run/docker.sock alizkan/jet-factory:1.0.0
            exit 0
        ;;
        $LINEAGE)
            echo -e "\nBuilding $ICOSA"
            docker run --security-opt apparmor:unconfined --cap-add SYS_ADMIN --privileged --rm -it -e DISTRO="$ICOSA" -v /dev:/dev -v "$basepath":/root/${distro} -v /var/run/docker.sock:/var/run/docker.sock alizkan/jet-factory:1.0.0
            exit 0
        ;;
        $ICOSA)
            echo -e "\nBuilding $ICOSA"
            docker run --security-opt apparmor:unconfined --cap-add SYS_ADMIN --privileged --rm -it -e DISTRO="$ICOSA" -v /dev:/dev -v "$basepath":/root/${distro} -v /var/run/docker.sock:/var/run/docker.sock alizkan/jet-factory:1.0.0
            exit 0
        ;;
        $FOSTER)
            echo -e "\nBuilding $FOSTER"
            docker run --security-opt apparmor:unconfined --cap-add SYS_ADMIN --privileged --rm -it -e DISTRO="$FOSTER" -v /dev:/dev -v "$basepath":/root/${distro} -v /var/run/docker.sock:/var/run/docker.sock alizkan/jet-factory:1.0.0
            exit 0
        ;;
        $FOSTER_TAB)
            echo "\nBuilding $FOSTER_TAB"
            docker run --security-opt apparmor:unconfined --cap-add SYS_ADMIN --privileged --rm -it -e DISTRO="$FOSTER_TAB" -v /dev:/dev -v "$basepath":/root/${distro} -v /var/run/docker.sock:/var/run/docker.sock alizkan/jet-factory:1.0.0
            exit 0
        ;;
        *) 
            echo -e "\n ==> Enter a number between 1 and 10"
            exit 1
        ;;
    esac
done