#!/usr/bin/env bash

echo "validate html" 

HTML_FILENAME="coverage.html"
#Exclude existing issue with OL nested in PRE
EXCLUSION_REGEX=".*Element\s.?ol.?\snot\sallowed\sas\schild\sof\selement\s.?pre.*"
HTML_VALIDATOR_URL="https://validator.w3.org/nu/"
VALIDATOR_OUT="gnu"
WARNING_REGEX="info warning:"
ERROR_REGEX="error:"

VALIDATION_RESULTS=$(curl -H "Content-Type: text/html; charset=utf-8" --data-binary @$HTML_FILENAME "$HTML_VALIDATOR_URL?out=$VALIDATOR_OUT&filterpattern=$EXCLUSION_REGEX")

ERROR_COUNT=`echo $VALIDATION_RESULTS | grep -c "$ERROR_REGEX"`
WARNING_COUNT=`echo $VALIDATION_RESULTS | grep -c "$WARNING_REGEX"`

echo "There are $ERROR_COUNT errors, $WARNING_COUNT warning  in $HTML_FILENAME"

if [ $ERROR_COUNT -gt 0 ]; then
 exit 1
else
 exit 0
fi