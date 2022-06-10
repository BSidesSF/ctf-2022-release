load("@rules_proto//proto:defs.bzl", "proto_library")
load("@rules_cc//cc:defs.bzl", "cc_binary", "cc_proto_library")
load("@com_github_grpc_grpc//bazel:cc_grpc_library.bzl", "cc_grpc_library")
load("@com_github_grpc_grpc//bazel:python_rules.bzl", "py_proto_library", "py_grpc_library")

proto_library(
    name = "rpcordle_proto",
    srcs = ["rpcordle.proto"],
)

cc_proto_library(
    name = "rpcordle_cc_proto",
    deps = [":rpcordle_proto"],
)

py_proto_library(
    name = "rpcordle_py_pb2",
    deps = [":rpcordle_proto"],
)

cc_grpc_library(
    name = "rpcordle_cc_grpc",
    srcs = [":rpcordle_proto"],
    deps = [":rpcordle_cc_proto"],
    grpc_only = True,
)

py_grpc_library(
    name = "rpcordle_py_pb2_grpc",
    srcs = [":rpcordle_proto"],
    deps = [":rpcordle_py_pb2"],
)

cc_binary(
    name = "rpcordle",
    srcs = [
        ":localsrc",
    ],
    deps = [
        ":rpcordle_cc_grpc",
        "@com_github_grpc_grpc//:grpc++",
        "@com_github_grpc_grpc//:grpc++_reflection",
    ]
)

cc_binary(
    name = "rpcordle-dbg",
    srcs = [
        ":localsrc",
    ],
    deps = [
        ":rpcordle_cc_grpc",
        "@com_github_grpc_grpc//:grpc++",
        "@com_github_grpc_grpc//:grpc++_reflection",
    ],
    local_defines = [
        "DEBUG_BUILD",
    ],
)

filegroup(
    name = "localsrc",
    srcs = [
        "main.cc",
        "game.cc",
        "server.cc",
        "game.h",
        "common.h",
    ],
)

