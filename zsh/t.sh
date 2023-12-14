#!/bin/bash

# Get current platform
if uname -a | grep -q "Darwin"; then
	export current_platform="Mac"

elif uname -a | grep -q "Ubuntu"; then
	export current_platform="Ubuntu"

else
	export current_platform="Other"
fi

if [["$current_platform" == "Ubuntu"]]; then
# if [ "$(uname)" == "Linux" ] && [ "$(lsb_release -si)" == "Ubuntu" ] && [ "$(basename $SHELL)" == "bash" ]; then
# if uname -a | grep -q "Ubuntu" && basename $SHELL | grep -q "bash"; then
    echo hihii
fi