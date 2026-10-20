# Інструкція використання

## Запуск агента

1. Відкрийте репозиторій у VS Code з увімкненим Copilot Chat.
2. Перейдіть у робочу гілку `feature`.
3. У Copilot Chat виконайте команду:

```text
/init
```

Команда `/init` запускає послідовність налаштування та генерації файлів
проєкту в робочій гілці `feature`. У гілці `develop` агент лише налаштовує
інструкції й не створює `Cargo.toml`, `src/`, `ci.sh`, `ci.bat` або workflow.

## Локальна перевірка

Виконуйте команди з кореня репозиторію:

```text
cargo test
cargo build --release
cargo run
```

`cargo test` запускає юніт-тести, `cargo build --release` перевіряє
production-збірку, а `cargo run` запускає програму. Після release-збірки
виконавчий файл має бути присутнім у `target/release/`.

## Запуск CI-скриптів

### Windows

У PowerShell або Command Prompt:

```powershell
.\ci.bat
```

### Linux/macOS

У shell:

```sh
./ci.sh
```

Перед запуском переконайтеся, що встановлено Rust toolchain і команда
`cargo` доступна в PATH.

## Артефакти GitHub Actions

Workflow запускає локальний CI-скрипт на кожній ОС, а потім завантажує
`target/release/` через `actions/upload-artifact@v4`. Артефакти мають імена
`rust-binaries-ubuntu-latest`, `rust-binaries-windows-latest` та
`rust-binaries-macos-latest` і містять виконавчий файл відповідної платформи.
Параметр `if-no-files-found: error` робить відсутність release-виконавця
помилкою workflow, тому порожній блок Artifacts не може бути помилково
прийнятий за успішну збірку.
