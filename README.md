# rules_openapi

Bazel rules for [openapi-generator CLI](https://github.com/OpenAPITools/openapi-generator).

## USAGE

WORKSPACE

```
git_repository(
    name = "rules_openapi",
    remote = "https://github.com/matsubara0507/rules_openapi",
    commit = "{any commit hash}",
)

load("@rules_openapi//openapi:toolchain.bzl", rules_openapi_toolchains = "toolchains")

rules_openapi_toolchains(version = "7.9.0")
```

BUILD is please see examples.
