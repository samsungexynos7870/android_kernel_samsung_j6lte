#!/bin/bash
#
# ice script
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software

# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

export ARCH=arm64
export CROSS_COMPILE="/home/fra/gcc/bin/aarch64-none-linux-gnu-"
export PLATFORM_VERSION=10

blv="-ice "

echo -e "select sublv: "
sublvs="beta alpha stable custom ice+"
selectsublv="1) beta
2) alpha
3) stable
4) custom
5) -ice+"

select slv in $sublvs
do
	case $slv in
		beta)
		export LOCALVERSION=$blv$slv
		break
		;;
		alpha)
		export LOCALVERSION=$blv$slv
		break
		;;
		stable)
		export LOCALVERSION=$blv$slv
		break
		;;
		custom)
		echo -e "insert slv"
		read nslv
		export LOCALVERSION=$nslv
		custom='y'
		break
		;;
		-ice+)
		export LOCALVERSION="-ice+"
		break
		;;
	esac
done

echo -e "do you want to clean? (y|n)"
read clean

if [[ $clean = 'y' ]]; then
	make clean
	make mrproper
	make distclean
fi

make j6lte-perf_defconfig
make exynos7870-j6lte_cis_ser_00.dtb
make exynos7870-j6lte_cis_ser_02.dtb
./tools/dtbtool arch/arm64/boot/dts/ -o arch/arm64/boot/dtb
PATH="/home/fra/proton-clang/bin:/home/fra/gcc/bin:${PATH}" \
make CC=clang -j69
rm -rf arch/arm64/boot/dts/*.dtb

if [[ ! -d "AnyKernel3" ]]; then
	git clone https://github.com/frasharp/AnyKernel3.git AnyKernel3
fi

zipname="ice$slv-$(date +'%d%m%Y')-$RANDOM"

rm ./AnyKernel3/Image ./AnyKernel3/dtb ./AnyKernel3/*.zip

cp ./arch/arm64/boot/Image ./AnyKernel3/
cp ./arch/arm64/boot/dtb ./AnyKernel3/

cd ./AnyKernel3
if [[ -f Image ]]; then
		while [[ -f ../$zipname ]]
		do
			if [[ $custom = 'y'  ]]; then
				zipname="ice$nslv-$(date +'%d%m%Y')-$RANDOM"
			else
				zipname="ice$slv-$(date +'%d%m%Y')-$RANDOM"
			fi
		done
	zip -r9 $zipname *
	cp *.zip ../
fi

