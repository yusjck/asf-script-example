#!/bin/bash

make(){
    if [ -e $1 ]; then
        echo ' *'${1##*/}
        if [ ! -e $2 ]; then
            mkdir $2
        fi
        cp $1 $2
    fi
}

if [ -e res ]; then
    rm -fR res
fi
mkdir res

if [ ! -e release ]; then
    mkdir release
fi

scriptdir=.
outputpath=release/latest.spk

echo 拷贝脚本文件
for file in ${scriptdir}/*.lua; do
    make $file res
done

echo 拷贝数据文件
for file in ${scriptdir}/data/*; do
    make $file res/data
done

echo 拷贝图片资源
for file in ${scriptdir}/pic/*; do
    make $file res/pic
done

echo 拷贝其它文件
make $scriptdir/icon.png res
make $scriptdir/UserVarDef.xml res
make $scriptdir/manifest.xml res

echo 写入编译时间
date '+%Y-%m-%d %H:%M:%S'>res/buildinfo.txt

echo 生成资源文件
7z a res.zip ./res/*>/dev/null
if [ -e $outputpath ]; then
    rm -f $outputpath
fi
mv res.zip $outputpath
rm -fR res
echo 资源打包完成，保存路径：$outputpath
