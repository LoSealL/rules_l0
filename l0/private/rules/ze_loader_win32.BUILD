"""
Copyright (c) 2025 Wenyi Tang
Author: Wenyi Tang
E-mail: wenyitang@outlook.com

"""

cc_import(
    name = "ze_loader_lib",
    interface_library = "lib/ze_loader.lib",
    system_provided = True,
    target_compatible_with = ["@platforms//os:windows"],
    alwayslink = False,
)

cc_import(
    name = "ze_tracing_layer_lib",
    hdrs = [
        ":include/level_zero/layers/zel_tracing_api.h",
        ":include/level_zero/layers/zel_tracing_ddi.h",
        ":include/level_zero/layers/zel_tracing_register_cb.h",
    ],
    interface_library = "lib/ze_tracing_layer.lib",
    system_provided = True,
    target_compatible_with = ["@platforms//os:windows"],
    alwayslink = False,
)

cc_import(
    name = "ze_validation_layer_lib",
    interface_library = "lib/ze_validation_layer.lib",
    system_provided = True,
    target_compatible_with = ["@platforms//os:windows"],
    alwayslink = False,
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
    deps = [":ze_loader_lib"],
)

alias(
    name = "level_zero",
    actual = ":ze_loader",
    visibility = ["//visibility:public"],
)

alias(
    name = "tracing_layer",
    actual = ":ze_tracing_layer_lib",
    visibility = ["//visibility:public"],
)

alias(
    name = "validation_layer",
    actual = ":ze_validation_layer_lib",
    visibility = ["//visibility:public"],
)
