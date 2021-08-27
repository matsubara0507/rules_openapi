#!/bin/bash

VERSION=$1

wget --quiet "https://repo1.maven.org/maven2/org/openapitools/openapi-generator-cli/${VERSION}/openapi-generator-cli-${VERSION}.jar"
shasum -a 256 "openapi-generator-cli-${VERSION}.jar"
rm "openapi-generator-cli-${VERSION}.jar"
