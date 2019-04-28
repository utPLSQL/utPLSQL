#!/bin/sh -e
echo "coveralls_uploader"
npm install request --save
npm install --save md5-file
cd "$(dirname "$(readlink -f "$0")")"
exec node coveralls_uploader.js
