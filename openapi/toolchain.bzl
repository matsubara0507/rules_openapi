DEFAULT_OPENAPI_REPOSITORY = "openapi_generator"

DEFAULT_VERSION = "7.9.0"

_OPENAPI_GENERATOR_CLI_JAR_BINDIST = \
    {
        "7.9.0": "f0cb7839a2ead9040b204519b03f1473b39c7725fd1f43134bb550515cb3dbee",
        "7.8.0": "d1879cf42da31f8cf61cf68798b8ef2418af0c6bd93a5c1870e1ff543fbb9365",
        "7.7.0": "3a757276c31d249a4f06a14651b1ff1f1a5cf46e110a70adcc4a6a2834f85561",
        "7.6.0": "35074bdd3cdfc46be9a902e11a54a3faa3cae1e34eb66cbd959d1c8070bbd7d7",
        "7.5.0": "47ebbd1beddaf7dfbee523e7b87623c6ec1b1d42960fbe15f6cad2f6426c69bf",
        "7.4.0": "e42769a98fef5634bee0f921e4b90786a6b3292aa11fe8d2f84c045ac435ab29",
        "7.3.0": "879c15340a75a19a7e720efc242c3223e0e4207b0694d6d1cea5c7dd87cf1cce",
        "7.2.0": "1cf0c80de12c0fdc8594289c19e414b402108ef10b8dd0bfda1953151341ab5d",
        "7.1.0": "85fab7a4d80a9e1e65c5824bcd375c39ad294af07490609529c8e78a7bda673a",
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
    name = "toolchain",
    openapi_generator_cli = ":{file_name}",
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

def _openapi_toolchains_repo_impl(ctx):
    build_context = """
toolchain(
    name = "toolchain",
    toolchain_type = "@rules_openapi//openapi:toolchain",
    toolchain = "@{repo_name}//:toolchain",
)
    """.format(repo_name = ctx.attr.repo_name)
    ctx.file("BUILD", content = build_context)


openapi_toolchains_repo = repository_rule(
    _openapi_toolchains_repo_impl,
    attrs = {
        "repo_name": attr.string(),
    },
)

def toolchains(name = DEFAULT_OPENAPI_REPOSITORY, version = DEFAULT_VERSION, register = True):
    if not _OPENAPI_GENERATOR_CLI_JAR_BINDIST.get(version):
        fail("JAR distribution of openapi-generetor-cli {} is not available.".format(version))

    checksum = _OPENAPI_GENERATOR_CLI_JAR_BINDIST.get(version)
    openapi_generator_cli_jar(name = name, version = version, checksum = checksum)
    if register:
        native.register_toolchains("@{}_toolchains//:toolchain".format(name))

    openapi_toolchains_repo(name = name + "_toolchains", repo_name = name)

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
