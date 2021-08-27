def _openapi_generate_impl(ctx):
    openapi_generator = ctx.toolchains["@rules_openapi//openapi:toolchain"].openapi_generator_cli
    inputs = [openapi_generator, ctx.file.spec] + ctx.files.deps

    arguments = [
        "-jar", openapi_generator.path, 
        "generate",
        "-i", ctx.file.spec.path,
        "-g", ctx.attr.generator, 
        "-o", ctx.outputs.out.path,
    ]

    if ctx.attr.template_dir:
        arguments += ["-t", ctx.attr.template_dir]

    ctx.actions.run_shell(
        command = "java {} 1>/dev/null".format(" ".join(arguments)),
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
            doc = "Dependency files (e.g. extra specs, templetes)"
        ),
        "generator": attr.string(mandatory = True),
        "template_dir": attr.label(),
    },
    toolchains = [
        "@rules_openapi//openapi:toolchain",
    ],
)