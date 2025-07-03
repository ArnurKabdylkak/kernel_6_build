#!/bin/bash -e
## TODO: Makefile!

#git clone https://github.com/nxp-imx/linux-imx.git
git -C linux-imx/ checkout lf-6.6.y

## Prepare out directory
mkdir -p build/modules

## Configuring kernel
cp src/my_defconfig linux-imx/arch/arm64/configs/ || exit 1
make -C linux-imx/ ARCH=arm64 -j8 CROSS_COMPILE=aarch64-linux-gnu- my_defconfig || exit 1
## Building
make -C linux-imx/ ARCH=arm64 -j8 CROSS_COMPILE=aarch64-linux-gnu- || exit 1
## Installing modules
make -C linux-imx/ ARCH=arm64 -j8 CROSS_COMPILE=aarch64-linux-gnu- modules_install INSTALL_MOD_PATH=`pwd`/build/modules || exit 1

cp linux-imx/arch/arm64/boot/Image ./build/ || exit 1
cp linux-imx/arch/arm64/boot/Image.gz ./build/ || exit 1

cpp -nostdinc -I linux-imx/include -I linux-imx/arch -I ./linux-imx/arch/arm64/boot/dts/freescale/  -undef -x assembler-with-cpp  ./src/tsk8mm1-linux.dts ./imx8mm-evk.dts.tmp || exit 1
./linux-imx/scripts/dtc/dtc -I dts -O dtb -o ./build/tsk8mm1.dtb ./imx8mm-evk.dts.tmp || exit 1
rm ./imx8mm-evk.dts.tmp

echo "All DONE!!!"
