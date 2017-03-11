#!/bin/bash
# Change working directory to project root
cd "${UTPLSQL_PROJECT_ROOT}"
mkdocs build --clean --strict
