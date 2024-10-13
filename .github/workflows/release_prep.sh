#!/usr/bin/env bash

set -o errexit -o nounset -o pipefail

# Set by GH actions, see
# https://docs.github.com/en/actions/learn-github-actions/environment-variables#default-environment-variables
TAG=${GITHUB_REF_NAME}
# The prefix is chosen to match what GitHub generates for source archives
# This guarantees that users can easily switch from a released artifact to a source archive
# with minimal differences in their code (e.g. strip_prefix remains the same)
PREFIX="rules_openapi-${TAG:1}"
ARCHIVE="rules_openapi-$TAG.tar.gz"

# NB: configuration for 'git archive' is in /.gitattributes
git archive --format=tar --prefix="${PREFIX}/" "${TAG}" | gzip > "$ARCHIVE"
SHA=$(shasum -a 256 "$ARCHIVE" | awk '{print $1}')

cat << EOF
## Using Bzlmod with Bazel 6 or greater

1. (Bazel 6 only) Enable with \`common --enable_bzlmod\` in \`.bazelrc\`.
2. Add to your \`MODULE.bazel\` file:

\`\`\`starlark
bazel_dep(name = "rules_openapi", version = "${TAG:1}")
openapi = use_extension("@rules_openapi//openapi:extensions.bzl", "openapi")
openapi.toolchain()
use_repo(openapi, "openapi_generator_toolchains")
register_toolchains("@openapi_generator_toolchains//:all")
\`\`\`

## Using WORKSPACE

Paste this snippet into your \`WORKSPACE.bazel\` file:

\`\`\`starlark
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
http_archive(
    name = "rules_openapi",
    sha256 = "${SHA}",
    strip_prefix = "${PREFIX}",
    url = "https://github.com/matsubara0507/rules_openapi/releases/download/${TAG}/${ARCHIVE}",
)

load("@rules_openapi//openapi:toolchain.bzl", rules_openapi_toolchains = "toolchains")
rules_openapi_toolchains()
\`\`\`
EOF