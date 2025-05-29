"""
Copyright (c) 2025 Wenyi Tang
Author: Wenyi Tang
E-mail: wenyitang@outlook.com

"""

cc_import(
    name = "libze_loader",
    shared_library = "lib/x86_64-linux-gnu/libze_loader.so",
    target_compatible_with = ["@platforms//os:linux"],
)

cc_import(
    name = "libze_tracing_layer",
    shared_library = "lib/x86_64-linux-gnu/libze_tracing_layer.so",
    target_compatible_with = ["@platforms//os:linux"],
)

cc_import(
    name = "libze_validation_layer",
    shared_library = "lib/x86_64-linux-gnu/libze_validation_layer.so",
    target_compatible_with = ["@platforms//os:linux"],
)

cc_library(
    name = "ze_loader",
    hdrs = [
        ":include/level_zero/loader/ze_loader.h",
        ":include/level_zero/ze_api.h",
        ":include/level_zero/ze_ddi.h",
        ":include/level_zero/zes_api.h",
        ":include/level_zero/zes_ddi.h",
        ":include/level_zero/zet_api.h",
        ":include/level_zero/zet_ddi.h",
    ],
    includes = [
        "include",
        "include/level_zero",
    ],
    deps = [":libze_loader"],
)

cc_library(
    name = "ze_tracing_layer",
    hdrs = [
        ":include/level_zero/layers/zel_tracing_api.h",
        ":include/level_zero/layers/zel_tracing_ddi.h",
        ":include/level_zero/layers/zel_tracing_register_cb.h",
    ],
    deps = [
        ":libze_tracing_layer",
        ":ze_loader",
    ],
)

cc_library(
    name = "ze_validation_layer",
    deps = [
        ":libze_validation_layer",
        ":ze_loader",
    ],
)

alias(
    name = "level_zero",
    actual = ":ze_loader",
    visibility = ["//visibility:public"],
)

alias(
    name = "tracing_layer",
    actual = ":ze_tracing_layer",
    visibility = ["//visibility:public"],
)

alias(
    name = "validation_layer",
    actual = ":ze_validation_layer",
    visibility = ["//visibility:public"],
)
