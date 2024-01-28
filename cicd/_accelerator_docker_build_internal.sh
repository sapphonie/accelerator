#!/bin/bash

set -euxo pipefail

bootstrapPkgs()
{
    # we really need to slim this shit down lol
    dpkg --add-architecture i386 &&     \
        apt-get update -y &&            \
        apt-get install -y              \
	--no-install-recommends		\
        build-essential                 \
        git                             \
        clang                           \
        python3-httplib2 python3-pip    \
        lib32stdc++-10-dev lib32z1-dev libc6-dev-i386 linux-libc-dev:i386 \
	libzstd-dev libzstd-dev:i386 zlib1g-dev zlib1g-dev:i386
}


#        libc6-dev-i386-cross            \

amTempLocation="_am_temp"
succCloneLocation="/accelerator/${amTempLocation}/successful_clone"
bootstrapAM()
{
    # need to install ambuild if we already cloned, otherwise checkout-deps will do it 4 us
    if test -f "${succCloneLocation}"; then
        pushd ${amTempLocation}
            pip install ./ambuild
        popd
        return 255;
    fi

    rm -rf /accelerator/"${amTempLocation}"/    || true
    mkdir -p ${amTempLocation}                  || exit 1
    pushd ${amTempLocation}                     || exit 1
        git clone --recursive https://github.com/alliedmodders/sourcemod || exit 1

        # skip downloading mysql we do not care about it
        bash sourcemod/tools/checkout-deps.sh -m || exit 1

        # we need to do this no matter what for some fcking reason
        pip install ./ambuild

        # make a blank file so that we don't reclone everything if we don't need to
        true > "${succCloneLocation}" || exit 1
    popd
}

# TODO: move this all into cicd folder
bootstrapBreakpad()
{
    bash breakpad.sh
}

buildIt()
{
    if test ! -d build; then
        mkdir -p build
    fi

    pushd build
        CC=clang CXX=clang++ python3 ../configure.py \
        --sm-path=/accelerator/${amTempLocation}/sourcemod/

# \
 #       --mms-path=/accelerator/${amTempLocation}/mmsource-1.12/    \
   #     --hl2sdk-root=/accelerator/${amTempLocation}/               \

        ambuild
    popd
}

###############################

cd /accelerator

bootstrapPkgs

git config --global --add safe.directory /
git config --global --add safe.directory /accelerator/breakpad


if bootstrapAM; then
    bootstrapBreakpad
else
    bootstrapBreakpad
fi

buildIt
