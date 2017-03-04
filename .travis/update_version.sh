#!/usr/bin/env bash
version=$TRAVIS_TAG
build_number=$TRAVIS_BUILD_NUMBER
version_placeholder='(utPLSQL - Version )X.X.X.X'
sources_directory='source'
function build_version_no(){
    version=$1
    build_number=$2
    #split version number and additional stuff after the number
    #so that: v3.0.0-develop will be changed to v.3.0.0.build_number-develop
    echo `sed -r "s/(v?[0-9]+\.)([0-9]+\.)([0-9]+)(-.*)/\1\2\3\.$build_number\4/" <<< "$version"`
}

version_with_build=`build_version_no ${version} ${build_number}`

find ${sources_directory} -type f -name '*' -exec sed -i -r "s/${version_placeholder}/\1${version_with_build}/" {} \;
