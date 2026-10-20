# Repository Guidelines

## Build and Test

The repository is a Rust/Cargo lab project. The initial repository contains
the instructional files; the `/init` workflow creates the Cargo project in a
working `feature` branch.

Run commands from the repository root after initialization:

```text
cargo fmt --check
cargo check
cargo build
cargo test
cargo run
```

To run one test, use Cargo's name filter, for example:

```text
cargo test BasicAddition
```

Run the complete platform-specific verification with `.\ci.bat` on Windows or
`./ci.sh` on Linux/macOS. These scripts perform the release build and tests.
The expected program output from `cargo run` includes `Hello, world!`.

## Architecture

This repository demonstrates a staged Copilot-driven Rust setup rather than a
large application:

- `.github/agents/build-engineer.agent.md` defines the Build Engineer role and
  its boundaries.
- `.github/skills/` contains the three stage implementations: project
  scaffolding, build/test work, and GitHub Actions setup.
- `.github/prompts/` composes those stages into the ordered
  `git-init -> create-project -> create-build -> create-actions -> check`
  workflow. Stop on the first failed stage.
- The eventual Rust package is a small binary: `src/main.rs` contains
  `main`, `add(a: i32, b: i32) -> i32`, and its unit test.
- `ci.sh` and `ci.bat` are the portable verification entry points.
  `.github/workflows/ci.yml` runs the appropriate script across
  `ubuntu-latest`, `windows-latest`, and `macos-latest`.

See [README.md](../README.md), [docs/architecture.md](../docs/architecture.md),
and [docs/usage.md](../docs/usage.md) for the workflow and design details.

## Repository Conventions

- Keep project generation restricted to the `feature` branch. The setup
  workflow must not create `Cargo.toml`, `src/`, CI scripts, or workflows while
  configuring instructions in `develop`.
- Preserve existing populated files and make setup operations idempotent:
  do not duplicate `target/`, `add`, `BasicAddition`, CI jobs, matrix entries,
  triggers, or script steps.
- The scaffold uses the exact Cargo package name `hello`, and the build stage
  uses the exact function signature `add(a: i32, b: i32) -> i32` and test name
  `BasicAddition`.
- Keep `target/` ignored and do not remove existing `.gitignore` rules.
- Put Cargo build/test commands in `ci.sh` and `ci.bat`; the GitHub Actions
  workflow invokes only the platform script and must not contain direct
  `cargo` commands.
- CI is one job with the three required runner labels and uses `push` and
  `pull_request` triggers for `develop` and `master`.
- Report failures with the exact command, file, and diagnostic. Do not mask
  failed checks with fallbacks or claim success when Cargo/tooling is missing.
- Limit edits to repository files, do not expose secrets, and do not rewrite
  Git history or delete files without explicit permission.
