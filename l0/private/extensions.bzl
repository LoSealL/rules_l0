"""
Copyright (c) 2025 Wenyi Tang
Author: Wenyi Tang
E-mail: wenyitang@outlook.com

"""

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

def _find_modules(module_ctx):
    root = None
    our_module = None
    for mod in module_ctx.modules:
        if mod.is_root:
            root = mod
        if mod.name == "rules_l0":
            our_module = mod
    if root == None:
        root = our_module

    return root, our_module

def load_zeloader(ctx):
    """Load oneAPI Level-zero

    release page:
    https://github.com/oneapi-src/level-zero/releases

    current version: 1.21.9

    Args:
        ctx: The module context.
    """

    VER_TO_HASH = {
        "1.21.9": "sha256-ulQ6Aa28vSQVGMPu6At1QUCU0f0+/N6f8mkxls6k0Fc=",
    }
    root, rules_l0 = _find_modules(ctx)
    download_installers = root.tags.download or rules_l0.tags.download

    for installer in download_installers:
        level_zero_version = installer.version
        integrity = installer.integrity
        if not integrity and level_zero_version in VER_TO_HASH:
            integrity = VER_TO_HASH[level_zero_version]

        http_archive(
            name = installer.name,
            build_file = "//l0/private/rules:ze_loader.BUILD",
            integrity = integrity,
            strip_prefix = "level-zero-%s" % level_zero_version,
            url = "https://github.com/oneapi-src/level-zero/archive/refs/tags/v%s.tar.gz" % level_zero_version,
        )

installer = module_extension(
    implementation = load_zeloader,
    tag_classes = {
        "download": tag_class(attrs = {
            "name": attr.string(default = "level_zero"),
            "version": attr.string(default = "1.21.9"),
            "integrity": attr.string(default = ""),
        }),
    },
)
