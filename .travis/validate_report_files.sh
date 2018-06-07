#!/usr/bin/env bash

GL_VALID=1

HTML_FILENAME="coverage.html"
JUNIT_FILENAME="junit_test_results.xml"
TFS_FILENAME="tfs_test_results.xml"
XSD_DIR="xsd"
XML_JAR_DIR="lib"
JUNIT_XSD="$$XSD_DIR/junit4.xsd"
TFS_XSD="$XSD_DIR/junit_windy.xsd"


#Exclude existing issue with OL nested in PRE
EXCLUSION_REGEX=".*Element\s.?ol.?\snot\sallowed\sas\schild\sof\selement\s.?pre.*"

#HTML Validation API
HTML_VALIDATOR_URL="https://validator.w3.org/nu/"
VALIDATOR_OUT="gnu"
WARNING_REGEX="info warning:"
ERROR_REGEX="error:"

#XML Validator
XML_VALIDATOR="$XML_JAR_DIR/xml_validator.jar"

#Validate HTML
HTML_VALIDATION_RESULTS=$(curl -H "Content-Type: text/html; charset=utf-8" --data-binary @$HTML_FILENAME "$HTML_VALIDATOR_URL?out=$VALIDATOR_OUT&filterpattern=$EXCLUSION_REGEX")

ERROR_COUNT=$(echo "$HTML_VALIDATION_RESULTS" | grep -c "$ERROR_REGEX")
WARNING_COUNT=$(echo "$HTML_VALIDATION_RESULTS" | grep -c "$WARNING_REGEX")

if [ "$ERROR_COUNT" -gt 0 ]; then
    GL_VALID=0
    echo ""
    echo "******************************"
    echo "HTML File is invalid"
    echo "There are $ERROR_COUNT errors, $WARNING_COUNT warning  in $HTML_FILENAME"
    echo "Please see results:"
    echo "$HTML_VALIDATION_RESULTS" | grep "$ERROR_REGEX"
fi


#Validate XML TFS_FILENAME
TFS_RESULT=$(java -jar $$XML_VALIDATOR -s $TFS_XSD $TFS_FILENAME 2>&1)

if [ $? -ne 0 ]; then
    GL_VALID=0
    echo ""
    echo "******************************"
    echo "TFS Test Result XML is invalid"
    echo "Please see results:"
    echo "$TFS_RESULT"
fi

#Validate XML JUNIT_FILENAME
JUNIT_RESULT=$(java -jar $XML_VALIDATOR -s $JUNIT_XSD $JUNIT_FILENAME 2>&1)

if [ $? -ne 0 ]; then
    GL_VALID=0
    echo ""
    echo "******************************"
    echo "JUNIT Test Result XML is invalid"
    echo "Please see results:"
    echo "$JUNIT_RESULT"
fi

if [ $GL_VALID -ne 1 ]; then
    echo ""
    echo "******************************"
    echo "Validation failed please see results above."
    exit 1
else
    exit 0
fi
