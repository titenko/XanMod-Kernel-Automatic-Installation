#!/bin/bash

# Register the PGP key
wget -qO - https://dl.xanmod.org/archive.key | sudo gpg --dearmor -o /usr/share/keyrings/xanmod-archive-keyring.gpg

# Add the repository
echo 'deb [signed-by=/usr/share/keyrings/xanmod-archive-keyring.gpg] http://deb.xanmod.org releases main' | sudo tee /etc/apt/sources.list.d/xanmod-release.list

echo "Select a branch:"
echo "1. main"
echo "2. lts"
echo "3. edge"
echo "4. rt"

branch=""
while [ "$branch" != "main" ] && [ "$branch" != "lts" ] && [ "$branch" != "edge" ] && [ "$branch" != "rt" ]; do
    read -p "Enter your choice (main/lts/edge/rt): " branch
done

while ! grep -q "flags" /proc/cpuinfo; do
    if [ $(wc -l < /proc/cpuinfo) -ne 1 ]; then
        exit 1
    fi
done

level=0
if grep -q "lm" /proc/cpuinfo && grep -q "cmov" /proc/cpuinfo && grep -q "cx8" /proc/cpuinfo && grep -q "fpu" /proc/cpuinfo && grep -q "fxsr" /proc/cpuinfo && grep -q "mmx" /proc/cpuinfo && grep -q "syscall" /proc/cpuinfo && grep -q "sse2" /proc/cpuinfo; then
    level=1
fi

if [ $level -eq 1 ] && grep -q "cx16" /proc/cpuinfo && grep -q "lahf" /proc/cpuinfo && grep -q "popcnt" /proc/cpuinfo && grep -q "sse4_1" /proc/cpuinfo && grep -q "sse4_2" /proc/cpuinfo && grep -q "ssse3" /proc/cpuinfo; then
    level=2
fi

if [ $level -eq 2 ] && grep -q "avx" /proc/cpuinfo && grep -q "avx2" /proc/cpuinfo && grep -q "bmi1" /proc/cpuinfo && grep -q "bmi2" /proc/cpuinfo && grep -q "f16c" /proc/cpuinfo && grep -q "fma" /proc/cpuinfo && grep -q "abm" /proc/cpuinfo && grep -q "movbe" /proc/cpuinfo && grep -q "xsave" /proc/cpuinfo; then
    level=3
fi

if [ $level -eq 3 ] && grep -q "avx512f" /proc/cpuinfo && grep -q "avx512bw" /proc/cpuinfo && grep -q "avx512cd" /proc/cpuinfo && grep -q "avx512dq" /proc/cpuinfo && grep -q "avx512vl" /proc/cpuinfo; then
    level=4
fi

if [ $level -gt 0 ]; then
    result="x64v$level"
    echo "Branch: $branch"
    echo $result

    # Generate and execute a setup command
    cmd="sudo apt install linux-xanmod-$branch-$result"
    eval $cmd

    exit $((level + 1))
fi

exit 1

