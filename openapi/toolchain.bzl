_DEFAULT_VERSION = "7.0.1"

_OPENAPI_GENERATOR_CLI_JAR_BINDIST = \
    {
        "7.0.1": "01387c73905de47a6ecf8801f91c8d61624f8a1e890c8058225df51d493bc32a",
        "6.6.0": "9718ff7844e89462c75dcd9b20a35136f6db257bfe1b874db1e3002e99de4609",
        "5.4.0": "f3ed312310e390324b33ba2ffff290ce812935207a1493ec5c098d0a441be51c",
        "5.2.1": "b2d46d4990af3d442e4e228e1e627b93ca371ad972f54a7e82272b0ce7968c8b",
        "5.2.0": "99960608847b5cebce3673450ccf3aa9233b8ae838f27a0d80170776293cd6f9",
        "5.1.1": "ed354fe3130c9c0d2a4f4e2bd25a60d7f439a58e66dcfcc907dc2a834840619f",
        "5.1.0": "62f9842f0fcd91e4afeafc33f19a7af41f2927c7472c601310cedfc72ff1bb19",
        "5.0.1": "e4e45d5441283b2f0f4bf988d02186b85425e7b708b4be0b06e3bfd7c7aa52c7",
        "5.0.0": "839fade01e54ce1eecf012b8c33adb1413cff0cf2e76e23bc8d7673f09626f8e",
        "4.3.1": "f438cd16bc1db28d3363e314cefb59384f252361db9cb1a04a322e7eb5b331c1",
    }

def _openapi_generator_cli_jar_impl(ctx):
    file_name = "openapi-generator-cli.jar"
    ctx.download(
        url = "https://repo1.maven.org/maven2/org/openapitools/openapi-generator-cli/{version}/openapi-generator-cli-{version}.jar".format(version = ctx.attr.version),
        sha256 = ctx.attr.checksum,
        output = file_name,
    )
    ctx.file(
        "BUILD",
        executable = False,
        content = """
load("@rules_openapi//openapi:toolchain.bzl", "openapi_toolchain")

exports_files(["{file_name}"])

openapi_toolchain(
    name = "openapi-generator-cli_info",
    openapi_generator_cli = ":{file_name}",
)

toolchain(
    name = "toolchain",
    toolchain_type = "@rules_openapi//openapi:toolchain",
    toolchain = ":openapi-generator-cli_info",
)
        """.format(file_name = file_name),
    )

openapi_generator_cli_jar = repository_rule(
    _openapi_generator_cli_jar_impl,
    local = False,
    attrs = {
        "version": attr.string(),
        "checksum": attr.string(),
    },
)

def toolchains(version = _DEFAULT_VERSION):
    if not _OPENAPI_GENERATOR_CLI_JAR_BINDIST.get(version):
        fail("JAR distribution of openapi-generetor-cli {} is not available.".format(version))

    checksum = _OPENAPI_GENERATOR_CLI_JAR_BINDIST.get(version)
    name = "openapi-generator-cli-toolchain"
    openapi_generator_cli_jar(name = name, version = version, checksum = checksum)
    native.register_toolchains("@{}//:toolchain".format(name))

def _openapi_toolchain_impl(ctx):
    return [platform_common.ToolchainInfo(
        openapi_generator_cli = ctx.file.openapi_generator_cli,
    )]

openapi_toolchain = rule(
    _openapi_toolchain_impl,
    attrs = {
        "openapi_generator_cli": attr.label(
            allow_single_file = True,
            mandatory = True,
        ),
    },
)
