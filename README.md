# Level-zero rules for [Bazel](https://bazel.build)

This repository contains [Starlark](https://github.com/bazelbuild/starlark) implementation of [L0](https://oneapi-src.github.io/level-zero-spec) rules in Bazel.

## Getting Started

### Traditional WORKSPACE approach

TBD

### Bzlmod

Add the following to your `MODULE.bazel` file and replace the placeholders with actual values.

```starlark

bazel_dep(name = "rules_l0", version = "0.1.0")
archive_override(
    module_name = "rules_l0",
    integrity = "{SRI value}",  # see https://developer.mozilla.org/en-US/docs/Web/Security/Subresource_Integrity
    urls = "https://github.com/loseall/rules_l0/archive/{git_commit_hash}.tar.gz",
    strip_prefix = "rules_l0-{git_commit_hash}",
)

l0_installer = use_extension("@rules_l0//l0:installer.bzl", "installer")
l0_installer.download(
    name = "level_zero",
    version = "1.21.9",
)
use_repo(l0_installer, "level_zero")
```

### Targets

- `@level_zero//:level_zero`: Basic ze_loader library. It should be an imported **ze_loader.dll** on windows, or a **libze_loader.so** on linux.
- `@level_zero//:validation_layer`: Validation layer library. It should be an imported **ze_validation_layer.dll** on windows, or a **libze_validation_layer.so** on linux.
- `@level_zero//:tracing_layer`: Tracing layer library. It should be an imported **ze_tracing_layer.dll** on windows, or a **libze_tracing_layer.so** on linux.

## Examples

Checkout the examples to see if it fits your needs.

See [examples](./examples) for basic usage.

## Known issue
