#!/bin/bash
set -e

# Using cd to remove the " from paths.
clientPath=$1
projectPath=$2
sourcePath=$3
testPath=$4

sqlFile=$clientPath/project_file_list.sql.tmp

function fileList {
    for f in $(find $projectPath/$1/* -type f | sed "s|$projectPath/||"); do
        echo "      '$f'," >> $sqlFile
    done
    echo "      null)]';" >> $sqlFile
}

echo "begin" > $sqlFile
echo "  null;" >> $sqlFile

if [ ! "$sourcePath" == "-" ]; then
    echo "  :l_file_list := q'[ut_varchar2_list(" >> $sqlFile
    fileList $sourcePath
fi

if [ ! "$testPath" == "-" ]; then
    echo "  :l_file_list := q'[ut_varchar2_list(" >> $sqlFile
    fileList $testPath
fi

echo "end;" >> $sqlFile
echo "/" >> $sqlFile
