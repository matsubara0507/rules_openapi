#!/bin/bash

for version in "$@"; do
  wget --quiet "https://repo1.maven.org/maven2/org/openapitools/openapi-generator-cli/${version}/openapi-generator-cli-${version}.jar"
  result=(`shasum -a 256 "openapi-generator-cli-${version}.jar"`)
  echo "\"${version}\": \"${result[0]}\","
  rm "openapi-generator-cli-${version}.jar"
done;
