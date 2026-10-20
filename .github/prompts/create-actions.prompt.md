---
description: "Викликає skill github-actions для створення локальних CI-скриптів і кросплатформного workflow."
argument-hint: "Створити ci.sh, ci.bat і GitHub Actions workflow"
agent: "Build Engineer AI Agent"
---

# Команда Create Actions

## Передумови

- `create-project` і `create-build` завершилися успішно.
- Існує коректний Rust-проєкт із `Cargo.toml`.
- Робота виконується у feature-гілці після `/init`.

## Дії

1. Виклич skill `github-actions`.
2. Створи `ci.sh` для Linux/macOS із release-збіркою та тестами.
3. Створи `ci.bat` для Windows із release-збіркою та тестами.
4. Створи `.github/workflows/ci.yml` з однією job і матрицею:
   `ubuntu-latest`, `windows-latest`, `macos-latest`.
5. Workflow має запускати лише `./ci.sh` на Unix і `.\ci.bat` на Windows.
6. Не додавай прямих викликів `cargo` у `ci.yml`.
7. Налаштуй тригери `push` і `pull_request` для гілок `develop` і `master`.

## Очікувані файли

- `ci.sh` з `cargo build --release` і `cargo test`.
- `ci.bat` з `cargo build --release` і `cargo test`.
- `.github/workflows/ci.yml` з однією job і трьома ОС.

## Команди перевірки

```text
./ci.sh
```

або у Windows:

```text
.\ci.bat
```

Статично перевір: одну job, три runner-и, умови запуску скриптів і відсутність
прямих `cargo`-викликів у workflow.

## Повідомлення про помилки

```text
FAIL create-actions: <файл або перевірка> завершилися з кодом <код>: <деталі>
```

Якщо manifest відсутній, зупинись. Якщо YAML некоректний або скрипт повертає
ненульовий код, передай точну діагностику без успішного fallback.

## Ідемпотентність

Не перезаписуй наявні заповнені скрипти чи workflow без потреби. Перед
зміною перевір їхню структуру; додавай відсутні налаштування лише один раз і
не дублюй job, matrix, triggers або кроки.

