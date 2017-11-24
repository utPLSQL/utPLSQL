#!/bin/bash
set -ev
cd $(dirname $(readlink -f $0))

# Download wagon-http recommended by Oracle.
# On maven latest version this is not needed, but travis doesn't have it.
if [ ! -f $CACHE_DIR/wagon-http-2.8-shaded.jar ]; then
    curl -L -O "http://central.maven.org/maven2/org/apache/maven/wagon/wagon-http/2.8/wagon-http-2.8-shaded.jar"
    mv wagon-http-2.8-shaded.jar $CACHE_DIR/
    sudo cp $CACHE_DIR/wagon-http-2.8-shaded.jar $MAVEN_HOME/lib/ext/
else
    echo "Using cached wagon-http..."
    sudo cp $CACHE_DIR/wagon-http-2.8-shaded.jar $MAVEN_HOME/lib/ext/
fi
