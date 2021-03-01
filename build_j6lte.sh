#!/bin/bash

export ARCH=arm64
export CROSS_COMPILE="/home/francesco/linaro/bin/aarch64-linux-gnu-"
export PLATFORM_VERSION=10

make j6lte_defconfig
make exynos7870-j6lte_cis_ser_00.dtb
make exynos7870-j6lte_cis_ser_02.dtb
./tools/dtbtool arch/arm64/boot/dts/ -o arch/arm64/boot/dtb
make -j10
rm -rf arch/arm64/boot/dts/*.dtb
