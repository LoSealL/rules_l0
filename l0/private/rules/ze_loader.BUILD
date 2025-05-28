"""
Copyright (c) 2025 Wenyi Tang
Author: Wenyi Tang
E-mail: wenyitang@outlook.com

bazel BUILD file for lib ze_loader
"""

# /// thirdparty libraries ///
# xla
cc_library(
    name = "xla",
    srcs = ["third_party/xla/graphcycles.cc"],
    hdrs = [
        "third_party/xla/graphcycles.h",
        "third_party/xla/ordered_set.h",
    ],
    includes = [
        "third_party",
        "third_party/xla",
    ],
)

LOADER_VERSION_MAJOR = "1"

LOADER_VERSION_MINOR = "21"

LOADER_VERSION_PATCH = "9"

LOADER_VERSION_SHA = "\\\"ba543a01adbcbd241518c3eee80b75414094d1fd3efcde9ff2693196cea4d057\\\""

ze_copts = select({
    "@platforms//os:windows": [
        "/std:c++14",
        "/guard:cf",
        "/W3",
        "/MP",
        "/EHsc",
        "/Z7",
        "/utf-8",
    ],
    "//conditions:default": [
        "-std=c++14",
        "-fpermissive",
        "-fPIC",
        "-fvisibility=hidden",
        "-fvisibility-inlines-hidden",
    ],
})

ze_linkopts = select({
    "@platforms//os:windows": [
        "/DEBUG",
        "/OPT:REF",
        "/OPT:ICF",
        "/CETCOMPAT",
    ],
    "//conditions:default": [],
})

ze_defines = [
    "LOADER_VERSION_MAJOR={}".format(LOADER_VERSION_MAJOR),
    "LOADER_VERSION_MINOR={}".format(LOADER_VERSION_MINOR),
    "LOADER_VERSION_PATCH={}".format(LOADER_VERSION_PATCH),
    "LOADER_VERSION_SHA={}".format(LOADER_VERSION_SHA),
]

filegroup(
    name = "cmakelists",
    srcs = ["CMakeLists.txt"],
    visibility = ["//visibility:public"],
)

filegroup(
    name = "lib",
    srcs = glob([
        "source/lib/*.cpp",
        "source/lib/*.h",
    ]) + select({
        "@platforms//os:windows": glob(["source/lib/windows/*.cpp"]),
        "//conditions:default": glob(["source/lib/linux/*.cpp"]),
    }),
    visibility = ["//visibility:private"],
)

filegroup(
    name = "loader",
    srcs = glob([
        "source/loader/*.cpp",
        "source/loader/*.h",
    ]) + select({
        "@platforms//os:windows": glob(["source/loader/windows/*.cpp"]),
        "//conditions:default": glob(["source/loader/linux/*.cpp"]),
    }),
    visibility = ["//visibility:private"],
)

cc_library(
    name = "ze_headers",
    hdrs = glob([
        "include/**",
    ]),
    includes = ["include"],
)

cc_library(
    name = "utils",
    srcs = ["source/utils/logging.cpp"],
    hdrs = ["source/utils/logging.h"],
    copts = ze_copts,
    defines = ze_defines,
    includes = [
        "source/inc",
        "source/utils",
    ],
    deps = [
        ":ze_headers",
        "@spdlog",
    ],
)

cc_binary(
    name = "ze_loader",
    srcs = [
        ":lib",
        ":loader",
    ] + glob(["source/inc/*.h"]),
    copts = ze_copts,
    defines = [
        "L0_LOADER_VERSION=\\\"1\\\"",
        "L0_VALIDATION_LAYER_SUPPORTED_VERSION=\\\"1\\\"",
    ],
    includes = ["source/inc"],
    linkopts = ze_linkopts + select({
        "@platforms//os:windows": [
            "-DEFAULTLIB:Advapi32.lib",
            "-DEFAULTLIB:cfgmgr32.lib",
            "-DEFAULTLIB:Ole32.lib",
        ],
        "//conditions:default": ["-ldl"],
    }),
    linkshared = True,
    deps = [
        ":utils",
        ":ze_headers",
    ],
)

filegroup(
    name = "ze_loader_lib",
    srcs = [":ze_loader"],
    output_group = "interface_library",
    target_compatible_with = ["@platforms//os:windows"],
)

cc_import(
    name = "ze_loader_dll",
    interface_library = ":ze_loader_lib",
    shared_library = ":ze_loader",
    target_compatible_with = ["@platforms//os:windows"],
)

cc_import(
    name = "ze_loader_so",
    shared_library = ":ze_loader",
    target_compatible_with = ["@platforms//os:linux"],
)

cc_library(
    name = "level_zero",
    visibility = ["//visibility:public"],
    deps = [":ze_loader"] + select({
        "@platforms//os:windows": [":ze_loader_dll"],
        "//conditions:default": [":ze_loader_so"],
    }),
)

cc_binary(
    name = "ze_validation_layer",
    srcs = glob([
        "source/layers/validation/**/*.cpp",
        "source/layers/validation/**/*.h",
    ]),
    copts = ze_copts,
    defines = ze_defines,
    includes = [
        "source/layers/validation",
        "source/layers/validation/checkers/parameter_validation",
        "source/layers/validation/checkers/template",
        "source/layers/validation/common",
        "source/layers/validation/handle_lifetime_tracking",
    ],
    linkopts = ze_linkopts,
    linkshared = True,
    deps = [
        ":utils",
        ":xla",
        ":ze_loader",
    ],
)

filegroup(
    name = "ze_validation_layer_lib",
    srcs = [":ze_validation_layer"],
    output_group = "interface_library",
    target_compatible_with = ["@platforms//os:windows"],
)

cc_import(
    name = "ze_validation_layer_dll",
    interface_library = ":ze_validation_layer_lib",
    shared_library = ":ze_validation_layer",
    target_compatible_with = ["@platforms//os:windows"],
)

cc_import(
    name = "ze_validation_layer_so",
    shared_library = ":ze_validation_layer",
    target_compatible_with = ["@platforms//os:linux"],
)

cc_library(
    name = "validation_layer",
    visibility = ["//visibility:public"],
    deps = [":ze_validation_layer"] + select({
        "@platforms//os:windows": [":ze_validation_layer_dll"],
        "//conditions:default": [":ze_validation_layer_so"],
    }),
)

cc_binary(
    name = "ze_tracing_layer",
    srcs = glob([
        "source/layers/tracing/*.cpp",
        "source/layers/tracing/*.h",
    ]) + select({
        "@platforms//os:windows": ["source/layers/tracing/windows/tracing_init.cpp"],
        "//conditions:default": ["source/layers/tracing/linux/tracing_init.cpp"],
    }),
    copts = ze_copts,
    defines = ze_defines,
    includes = [
        "source/layers/validation",
    ],
    linkopts = ze_linkopts,
    linkshared = True,
    deps = [
        ":utils",
        ":ze_loader",
    ],
)

filegroup(
    name = "ze_tracing_layer_lib",
    srcs = [":ze_tracing_layer"],
    output_group = "interface_library",
    target_compatible_with = ["@platforms//os:windows"],
)

cc_import(
    name = "ze_tracing_layer_dll",
    interface_library = ":ze_tracing_layer_lib",
    shared_library = ":ze_tracing_layer",
    target_compatible_with = ["@platforms//os:windows"],
)

cc_import(
    name = "ze_tracing_layer_so",
    shared_library = ":ze_tracing_layer",
    target_compatible_with = ["@platforms//os:linux"],
)

cc_library(
    name = "tracing_layer",
    visibility = ["//visibility:public"],
    deps = [":ze_tracing_layer"] + select({
        "@platforms//os:windows": [":ze_tracing_layer_dll"],
        "//conditions:default": [":ze_tracing_layer_so"],
    }),
)
