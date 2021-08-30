def _openapi_generate_impl(ctx):
    openapi_generator = ctx.toolchains["@rules_openapi//openapi:toolchain"].openapi_generator_cli
    inputs = [openapi_generator, ctx.file.spec] + ctx.files.deps + ctx.files.java_runtime

    arguments = [
        "-jar", openapi_generator.path, 
        "generate",
        "-i", ctx.file.spec.path,
        "-g", ctx.attr.generator, 
        "-o", ctx.outputs.out.path,
    ]

    if ctx.attr.template_dir:
        arguments += ["-t", ctx.attr.template_dir.label.package]
        inputs += ctx.files.template_dir

    java_home = ctx.attr.java_runtime[java_common.JavaRuntimeInfo].java_home
    ctx.actions.run_shell(
        command = "{path}/bin/java {args} 1>/dev/null".format(path = java_home, args = " ".join(arguments)),
        inputs = inputs,
        outputs = [ctx.outputs.out],
    )

openapi_generate = rule(
    _openapi_generate_impl,
    attrs = {
        "spec": attr.label(
            mandatory = True,
            allow_single_file = [
                ".json",
                ".yaml",
            ],
            doc = "OpenAPI spec file",
        ),
        "out": attr.output(mandatory = True),
        "deps": attr.label_list(
            doc = "Dependency files (e.g. extra specs)",
            allow_files = True,
        ),
        "generator": attr.string(mandatory = True),
        "template_dir": attr.label(),
        "java_runtime": attr.label(
            doc = "Java runtime to exec openapi-generator-cli.jar (default is host runtime)",
            default = Label("@bazel_tools//tools/jdk:current_host_java_runtime"),
            providers = [java_common.JavaRuntimeInfo],
        ),
    },
    toolchains = [
        "@rules_openapi//openapi:toolchain",
    ],
)
