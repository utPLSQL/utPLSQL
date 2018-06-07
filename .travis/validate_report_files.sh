#!/usr/bin/env bash

GL_VALID=1
XSD_DIR="$TRAVIS_BUILD_DIR/.travis/xsd"
XML_JAR_DIR="$TRAVIS_BUILD_DIR/.travis/lib"
#XML Validator
XML_VALIDATOR="$XML_JAR_DIR/xml_validator.jar"
HTML_VALIDATOR_URL="https://validator.w3.org/nu/"

HTML_FILENAME="coverage.html"
declare -A XML_FILES
XML_FILES["junit_test_results.xml"]="junit4.xsd"   
XML_FILES["tfs_test_results.xml"]="junit_windy.xsd"

function ValidateHtml {
    EXCLUSION_REGEX=".*Element\s.?ol.?\snot\sallowed\sas\schild\sof\selement\s.?pre.*"
    #HTML Validation API
    VALIDATOR_OUT="gnu"
    WARNING_REGEX="info warning:"
    ERROR_REGEX="error:"
    #Validate HTML
    HTML_VALIDATION_RESULTS=$(curl -H "Content-Type: text/html; charset=utf-8" --data-binary @$1 "$HTML_VALIDATOR_URL?out=$VALIDATOR_OUT&filterpattern=$EXCLUSION_REGEX")

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
}

function ValidateXML() {
    echo "Validate File $2 against schema $1"
    VALIDATION_RESULT=$(java -jar $XML_VALIDATOR -s $1 $2 2>&1)
        
    if [ $? -ne 0 ]; then
        GL_VALID=0
        echo ""
        echo "******************************"
        echo "XML is invalid"
        echo "Please see results:"
        echo "$VALIDATION_RESULT"
    fi
}

ValidateHtml "$HTML_FILENAME"

for XMLFILE in "${!XML_FILES[@]}"; do 
    #echo "$XMLFILE" "${XML_FILES[$XMLFILE]}"; 
    ValidateXML "XSD_DIR/${XML_FILES[$XMLFILE]}" "$XMLFILE"
done

if [ $GL_VALID -ne 1 ]; then
    echo ""
    echo "******************************"
    echo "Validation failed please see results above."
    exit 1
else
    exit 0
fi
