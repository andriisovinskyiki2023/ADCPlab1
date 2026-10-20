---
name: github-actions
description: 'Створення кросплатформного Rust CI у GitHub Actions через ci.sh і ci.bat. Застосовуй після /init для матриці Ubuntu, Windows і macOS без прямих cargo-команд у ci.yml.'
argument-hint: 'Шлях до Rust проєкту та цільові ОС'
user-invocable: true
disable-model-invocation: false
---

# GitHub Actions

## Коли застосовувати

Застосовуй у feature-гілці після `/init`, коли Rust-проєкт уже має
`Cargo.toml` і `src/`, а потрібно додати однакову локальну та CI-перевірку
для Linux, macOS і Windows. Цей skill не створює проєктний код під час
налаштування інструкцій у `develop`.

## Вхідні дані

Потрібні:

- існуючий Rust-проєкт у feature-гілці;
- `Cargo.toml` і вихідний код;
- три цільові ОС: `ubuntu-latest`, `windows-latest`, `macos-latest`;
- вимога запускати CI лише через платформний скрипт.

Приклад входу:

```text
Створи GitHub Actions CI для Rust з однією job і матрицею Ubuntu, Windows
та macOS. Workflow має запускати лише ci.sh або ci.bat, без cargo-команд.
```

## Вихідні файли

Створи у feature-гілці лише такі CI-файли:

- `ci.sh` для Linux/macOS;
- `ci.bat` для Windows;
- `.github/workflows/ci.yml`.

`ci.sh` і `ci.bat` повинні виконувати release-збірку та тести:

```text
cargo build --release
cargo test
```

`ci.yml` повинен містити одну job із матрицею:

- `ubuntu-latest`;
- `windows-latest`;
- `macos-latest`.

Workflow має запускати **ВИКЛЮЧНО** `ci.sh` або `ci.bat` залежно від ОС.
У `ci.yml` не можна додавати прямі виклики `cargo`.
Після успішного запуску скрипта workflow повинен завантажувати release-
результат через `actions/upload-artifact@v4`. Крок завантаження має:

- виконуватися після кроку запуску CI-скрипта;
- мати унікальне ім'я на основі ОС, наприклад
  `rust-binaries-${{ matrix.os }}`;
- завантажувати `target/release/`;
- містити `if-no-files-found: error`, щоб порожній artifact був помилкою.

У завантаженому каталозі має бути виконавчий файл Cargo-пакета
(`target/release/<package-name>` на Unix або
`target/release/<package-name>.exe` на Windows).

## Покрокові дії

1. Перевір, що робота виконується у feature-гілці після `/init` і що
   `Cargo.toml` уже існує.
2. Створи `ci.sh` з POSIX shell, `set -eu`, release-збіркою та тестами.
   Зроби файл виконуваним для Linux/macOS.
3. Створи `ci.bat` з перевіркою `%errorlevel%` після кожної команди,
   release-збіркою та тестами.
4. Створи `.github/workflows/ci.yml` з однією job, наприклад `ci`, і
   `strategy.matrix.os` із трьома точними назвами runner-ів.
5. Додай checkout і встановлення стабільного Rust toolchain як підготовчі
   кроки, якщо вони потрібні.
6. Додай умовні кроки запуску скриптів:

   ```yaml
   - name: Run Unix CI script
     if: runner.os != 'Windows'
     run: ./ci.sh

   - name: Run Windows CI script
     if: runner.os == 'Windows'
     run: .\ci.bat
   ```

7. Додай після цих умовних кроків спільний крок завантаження:

   ```yaml
   - name: Upload release binaries
     uses: actions/upload-artifact@v4
     with:
       name: rust-binaries-${{ matrix.os }}
       path: target/release/
       if-no-files-found: error
   ```

8. Перевір, що в `ci.yml` немає рядків `cargo test`, `cargo build` або
   інших прямих викликів Cargo.
9. Перевір, що artifact налаштований для кожної матричної ОС і містить
   release-виконавчий файл.
10. Передай оркестратору перелік CI-файлів, artifact-параметри та результати
    локальної перевірки.

## Перевірка результату

Перевір статично:

1. існують `ci.sh`, `ci.bat` і `.github/workflows/ci.yml`;
2. у скриптах є `cargo build --release` і `cargo test`;
3. workflow має лише одну job;
4. матриця містить усі три runner-и без додаткових ОС;
5. Unix runner запускає тільки `./ci.sh`, Windows runner — тільки
   `.\ci.bat`;
6. у `ci.yml` немає прямих викликів `cargo`;
7. є `actions/upload-artifact@v4` після CI-скрипта;
8. artifact має унікальне ім'я для матричної ОС, шлях `target/release/` і
   `if-no-files-found: error`;
9. release-каталог містить виконавчий файл для поточної ОС.

Перевір локально на відповідній платформі:

```text
./ci.sh
```

або:

```text
.\ci.bat
```

Обидві команди мають завершитися з кодом `0`.
Після локального release-build перевір, що в `target/release/` створено
виконавчий файл, який workflow завантажить як artifact.

## Типові сценарії помилок та їх виправлення

- **У `ci.yml` є прямий виклик Cargo.** Видали його з workflow і перенеси
  release-збірку та тестування у `ci.sh`/`ci.bat`.
- **Workflow має більше однієї job.** Об'єднай CI-кроки в одну job із
  матрицею `strategy.matrix.os`.
- **Відсутня ОС у матриці.** Додай точні значення
  `ubuntu-latest`, `windows-latest`, `macos-latest`.
- **Unix-скрипт не запускається.** Додай права виконання через Git і
  перевір shebang `#!/usr/bin/env sh`; не замінюй його Windows-командами.
- **Windows-скрипт продовжує роботу після помилки.** Додай перевірку
  `errorlevel` після кожної команди та поверни ненульовий код.
- **Workflow не знаходить скрипт.** Переконайся, що `run` виконується з
  кореня репозиторію та використовує `./ci.sh` або `.\ci.bat`.
- **Скрипти відсутні в develop.** Це очікувано до `/init`; створюй їх лише
  у feature-гілці за вимогою цього skill.
