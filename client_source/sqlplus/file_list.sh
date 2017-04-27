#!/bin/bash
set -e

pathParam=$1

# Trick to get the full path from relative one.
currentDir=$(pwd)
cd $pathParam
projectPath=$(pwd)
cd $currentDir

sqlFile=project_file_list.sql.tmp

echo "begin" > $sqlFile
echo "  :l_file_list := q'[ut_varchar2_list(" >> $sqlFile
for f in $(find $projectPath -type f | sed "s|$projectPath/||"); do
    echo "      '$f'," >> $sqlFile
done
echo "      null)]';" >> $sqlFile
echo "end;" >> $sqlFile
echo "/" >> $sqlFile
