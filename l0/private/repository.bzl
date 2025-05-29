"""
Copyright (c) 2025 Wenyi Tang
Author: Wenyi Tang
E-mail: wenyitang@outlook.com

"""

load("@bazel_tools//tools/build_defs/repo:cache.bzl", "get_default_canonical_id")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "update_attrs")

def _get_source_urls(ctx):
    """Returns source urls provided via the url, urls attributes.

    Also checks that at least one url is provided."""
    if not ctx.attr.url and not ctx.attr.urls:
        fail("At least one of url and urls must be provided")

    source_urls = []
    if ctx.attr.urls:
        source_urls = ctx.attr.urls
    if ctx.attr.url:
        source_urls = [ctx.attr.url] + source_urls
    return source_urls

def _download_source_impl(ctx):
    """Implementation of the http_archive rule."""
    source_urls = _get_source_urls(ctx)
    download_info = ctx.download_and_extract(
        source_urls,  # url=
        "",  # add_prefix=
        "",  # sha256=
        ctx.attr.type,  # type=
        ctx.attr.strip_prefix,  # strip_prefix=
        canonical_id = get_default_canonical_id(ctx, source_urls),
        integrity = ctx.attr.integrity,
    )
    ctx.template(
        "BUILD",
        ctx.attr.build_file,
        {
            "%{version_major}": ctx.attr.version_major,
            "%{version_minor}": ctx.attr.version_minor,
            "%{version_patch}": ctx.attr.version_patch,
            "%{version_sha}": ctx.attr.version_sha,
        },
    )
    return update_attrs(
        ctx.attr,
        ["integrity", "url", "urls", "build_file", "version_major", "version_minor", "version_patch", "version_sha", "strip_prefix"],
        {"integrity": download_info.integrity},
    )

_default_attr = {
    "strip_prefix": attr.string(
        doc = """A directory prefix to strip from the extracted files.

Many archives contain a top-level directory that contains all of the useful
files in archive. Instead of needing to specify this prefix over and over
in the `build_file`, this field can be used to strip it from all of the
extracted files.

For example, suppose you are using `foo-lib-latest.zip`, which contains the
directory `foo-lib-1.2.3/` under which there is a `WORKSPACE` file and are
`src/`, `lib/`, and `test/` directories that contain the actual code you
wish to build. Specify `strip_prefix = "foo-lib-1.2.3"` to use the
`foo-lib-1.2.3` directory as your top-level directory.

Note that if there are files outside of this directory, they will be
discarded and inaccessible (e.g., a top-level license file). This includes
files/directories that start with the prefix but are not in the directory
(e.g., `foo-lib-1.2.3.release-notes`). If the specified prefix does not
match a directory in the archive, Bazel will return an error.""",
    ),
    "build_file": attr.label(
        allow_single_file = True,
        mandatory = True,
        doc =
            "The file to use as the BUILD file for this repository." +
            "This attribute is an absolute label (use '@//' for the main " +
            "repo). The file does not need to be named BUILD, but can " +
            "be (something like BUILD.new-repo-name may work well for " +
            "distinguishing it from the repository's actual BUILD files. " +
            "Either build_file or build_file_content can be specified, but " +
            "not both.",
    ),
}

download_source = repository_rule(
    implementation = _download_source_impl,
    attrs = {
        "url": attr.string(),
        "urls": attr.string_list(),
        "type": attr.string(
            doc = """The archive type of the downloaded file.

By default, the archive type is determined from the file extension of the
URL. If the file has no extension, you can explicitly specify one of the
following: `"zip"`, `"jar"`, `"war"`, `"aar"`, `"tar"`, `"tar.gz"`, `"tgz"`,
`"tar.xz"`, `"txz"`, `"tar.zst"`, `"tzst"`, `"tar.bz2"`, `"ar"`, or `"deb"`.""",
        ),
        "integrity": attr.string(
            doc = """Expected checksum in Subresource Integrity format of the file downloaded.

This must match the checksum of the file downloaded. _It is a security risk
to omit the checksum as remote files can change._ At best omitting this
field will make your build non-hermetic. It is optional to make development
easier but either this attribute or `sha256` should be set before shipping.""",
        ),
        "version_major": attr.string(),
        "version_minor": attr.string(),
        "version_patch": attr.string(),
        "version_sha": attr.string(),
    } | _default_attr,
    doc = "Bazel rule for Level Zero loader library.",
)

def _open_deb(ctx, strip_prefix):
    # extract deb contents
    ctx.extract(
        "data.tar.gz",
        "",  # output=
        strip_prefix,
    )
    ctx.delete("data.tar.gz")
    ctx.delete("control.tar.gz")

def _extract_deb_impl(ctx):
    """Implementation of the deb_extract rule."""

    # download dev headers
    devel_info = ctx.download_and_extract(
        ctx.attr.dev_url,  # url=
        "",  # output=
        "",  # sha256=
        ctx.attr._type,  # type=
        ctx.attr.strip_prefix,  # strip_prefix=
        # integrity = ctx.attr.integrity[0],
    )
    _open_deb(ctx, "usr")

    # download so libraries
    so_info = ctx.download_and_extract(
        ctx.attr.url,
        "",  # output=
        "",  # sha256=
        ctx.attr._type,  # type=
        ctx.attr.strip_prefix,  # strip_prefix=
        # integrity = ctx.attr.integrity[1],
    )
    _open_deb(ctx, "usr")

    ctx.template("BUILD", ctx.attr.build_file, {})
    return update_attrs(
        ctx.attr,
        ["integrity", "dev_url", "url", "build_file"],
        {"integrity": [devel_info.integrity, so_info.integrity]},
    )

extract_deb = repository_rule(
    implementation = _extract_deb_impl,
    attrs = {
        "dev_url": attr.string(),
        "url": attr.string(),
        "integrity": attr.string_list(
            doc = """Expected checksum in Subresource Integrity format of the file downloaded.

This must match the checksum of the file downloaded. _It is a security risk
to omit the checksum as remote files can change._ At best omitting this
field will make your build non-hermetic. It is optional to make development
easier but either this attribute or `sha256` should be set before shipping.""",
        ),
        "_type": attr.string(default = "deb"),
    } | _default_attr,
)
