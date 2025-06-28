#!/usr/bin/env bash

RUSTUP_VERSION=1.28.2

function get_sha256() {
    local arch=$1
    local url="https://static.rust-lang.org/rustup/archive/${RUSTUP_VERSION}/${arch}/rustup-init"
    echo "rustup/${RUSTUP_VERSION}/${arch} $(curl -sSL ${url} | sha256sum | awk '{print $1}')"
}

get_sha256 "aarch64-unknown-linux-gnu"
get_sha256 "x86_64-unknown-linux-gnu"
