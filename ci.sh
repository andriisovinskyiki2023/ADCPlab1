#!/usr/bin/env sh
set -eu

cargo build --release
cargo test
