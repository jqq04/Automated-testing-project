#!/bin/bash

export CC=clang-12
export CFLAGS="-O0 -fexperimental-new-pass-manager -fpass-plugin=/usr/lib/mull-ir-frontend-12 -g -grecord-command-line"

./configure
./make

target_arr=("size" "readelf" "objdump" "cxxfilt" "strip_new" "nm_new")​
for target in ${target_arr[@]}; do
	dir=`ls ../${target}_fuzz_out/queue`
	for file in ${dir}; do
		if [ ${file:10:3} = "src" ]; then
			mull-runner-12 ./binutils/${target} ../${target}_fuzz_out/queue/${file} --report-dir ../${target}_report_dir  --reporters Elements --no-output --report-name $file
		fi
	done
done

