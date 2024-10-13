load(
    ":toolchain.bzl",
    "DEFAULT_OPENAPI_REPOSITORY",
    "DEFAULT_VERSION",
    register_toolchains = "toolchains",
)

def _find_modules(ctx):
    root = None
    our_module = None
    for mod in ctx.modules:
        if mod.is_root:
            root = mod
        if mod.name == "rules_openapi":
            our_module = mod
    if root == None:
        root = our_module
    if our_module == None:
        fail("Unable to find rules_openapi module")

    return root, our_module

def _openapi_module_extension_impl(ctx):
    root, rules_openapi = _find_modules(ctx)
    toolchains = root.tags.toolchain or rules_openapi.tags.toolchain
    for toolchain in toolchains:
        register_toolchains(
            name = toolchain.name,
            version = toolchain.version,
            register = False,
        )

openapi = module_extension(
    _openapi_module_extension_impl,
    tag_classes = {
        "toolchain": tag_class(attrs = {
            "name": attr.string(
                default = DEFAULT_OPENAPI_REPOSITORY,
            ),
            "version": attr.string(
                default = DEFAULT_VERSION,
            )
        }),
    },
)