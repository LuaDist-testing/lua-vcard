#!/bin/bash

for f in ./test/*.vcf; do
	output=$(./test/test.lua $f);
	if [[ $output == "nil"* ]]; then
		echo "file $f failed";
	fi;
done
