load("@rules_proto//proto:defs.bzl", "proto_library")
load("@rules_cc//cc:defs.bzl", "cc_binary", "cc_proto_library")
load("@com_github_grpc_grpc//bazel:cc_grpc_library.bzl", "cc_grpc_library")
load("@com_github_grpc_grpc//bazel:python_rules.bzl", "py_proto_library", "py_grpc_library")

proto_library(
    name = "rpcordle_proto",
    srcs = ["rpcordle.proto"],
)

py_proto_library(
    name = "rpcordle_pb2",
    deps = [":rpcordle_proto"],
)

py_grpc_library(
    name = "rpcordle_pb2_grpc",
    srcs = [":rpcordle_proto"],
    deps = [":rpcordle_pb2"],
)

py_binary(
    name = "solver",
    srcs = ["solver.py"],
    deps = [":rpcordle_pb2_grpc"],
)
