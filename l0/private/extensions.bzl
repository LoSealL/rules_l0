"""
Copyright (c) 2025 Wenyi Tang
Author: Wenyi Tang
E-mail: wenyitang@outlook.com

"""

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load(":repository.bzl", "download_source", "extract_deb")

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
    if root == None and our_module == None:
        fail("Can't find rules_l0 module: ({} {})".format(root, our_module))

    return root, our_module

def _is_windows(os_name):
    return "windows" in os_name

def _canonical_os_name(os_name):
    return "windows" if _is_windows(os_name) else "linux"

def _compile_from_sources(download_installers):
    VER_TO_HASH = {
        "1.21.9": "sha256-ulQ6Aa28vSQVGMPu6At1QUCU0f0+/N6f8mkxls6k0Fc=",
    }

    for installer in download_installers:
        level_zero_version = installer.version
        version_major, version_minor, version_patch = level_zero_version.split(".")
        integrity = installer.integrity
        if not integrity and level_zero_version in VER_TO_HASH:
            integrity = VER_TO_HASH[level_zero_version]

        download_source(
            name = installer.name,
            build_file = "//l0/private/template:ze_loader.tpl",
            integrity = integrity,
            strip_prefix = "level-zero-%s" % level_zero_version,
            url = "https://github.com/oneapi-src/level-zero/archive/refs/tags/v%s.tar.gz" % level_zero_version,
            version_major = version_major,
            version_minor = version_minor,
            version_patch = version_patch,
            version_sha = integrity,
        )

def _prebuilt_binaries(ctx, installers):
    VER_TO_HASH = {
        "windows": {"1.21.9": "sha256-uldv3yxyb+rLtH+Rar7MpcRU8/vXADK4P02Jw18s3YM="},
        "linux": {
            # two sha256 the 1st is for devel and the 2nd is for runtime
            "1.21.9": [
                "sha256-22STk80QFMUx1eeqT5WxPpSym9V8c2+lWKwpfxhVzTo=",
                "sha256-SBVOrpSeF7WhgGqlmI8AE6SQoGKlxi+mNdSpfe1EKyY=",
            ],
        },
    }
    hashmap = VER_TO_HASH[_canonical_os_name(ctx.os.name)]

    for installer in installers:
        level_zero_version = installer.version
        integrity = installer.integrity
        if not integrity and level_zero_version in VER_TO_HASH:
            integrity = hashmap[level_zero_version]

        if _is_windows(ctx.os.name):
            http_archive(
                name = installer.name,
                build_file = "//l0/private/rules:ze_loader_win32.BUILD",
                integrity = integrity,
                url = "https://github.com/oneapi-src/level-zero/releases/download/v{0}/level-zero-win-sdk-{0}.zip".format(level_zero_version),
            )
        else:
            os_version = "u24.04_amd64"
            extract_deb(
                name = installer.name,
                build_file = "//l0/private/rules:ze_loader_unix.BUILD",
                integrity = integrity,
                dev_url = "https://github.com/oneapi-src/level-zero/releases/download/v{0}/level-zero-devel_{0}+{1}.deb".format(
                    level_zero_version,
                    os_version,
                ),
                url = "https://github.com/oneapi-src/level-zero/releases/download/v{0}/level-zero_{0}+{1}.deb".format(
                    level_zero_version,
                    os_version,
                ),
            )

def load_zeloader(ctx):
    """Load oneAPI Level-zero

    release page:
    https://github.com/oneapi-src/level-zero/releases

    current version: 1.21.9

    Args:
        ctx: The module context.
    """

    root, rules_l0 = _find_modules(ctx)
    if root.tags.compile_from_source:
        download_installers = root.tags.compile_from_source or (rules_l0 != None and rules_l0.tags.compile_from_source)
        _compile_from_sources(download_installers)

    if root.tags.download_prebuilt:
        prebuilt_installers = root.tags.download_prebuilt or rules_l0.tags.download_prebuilt
        _prebuilt_binaries(ctx, prebuilt_installers)

installer = module_extension(
    implementation = load_zeloader,
    tag_classes = {
        "compile_from_source": tag_class(attrs = {
            "name": attr.string(default = "level_zero"),
            "version": attr.string(default = "1.21.9"),
            "integrity": attr.string(default = ""),
        }),
        "download_prebuilt": tag_class(attrs = {
            "name": attr.string(default = "level_zero"),
            "version": attr.string(default = "1.21.9"),
            "integrity": attr.string(default = ""),
        }),
    },
)
