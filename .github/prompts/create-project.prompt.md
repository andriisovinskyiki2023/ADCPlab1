---
description: "Створює базовий Hello World проєкт Rust через skill project-scaffold і cargo init."
argument-hint: "Створити Rust-проєкт з пакетом hello"
agent: "Build Engineer AI Agent"
---

# Команда Create Project

## Передумови

- Команда запускається після `git-init` у робочій feature-гілці.
- Команда `/init` уже активувала оркестрацію.
- Cargo встановлений і доступний у PATH.
- Заборонено створювати проєктні файли в гілці `develop`.

## Дії

1. Виклич skill `project-scaffold`.
2. Перевір, що поточний каталог є коренем репозиторію.
3. Якщо `Cargo.toml` і `src/main.rs` уже існують та заповнені, не
   перезаписуй їх; перевір їх і передай оркестратору статус `already present`.
4. В іншому разі створюй проєкт СУВОРО цією командою:

   ```text
   cargo init --bin --name hello
   ```

5. Переконайся, що команда згенерувала пакет `hello`, `Cargo.toml`,
   `src/main.rs` і не видалила наявні правила `.gitignore`.
6. Не створюй `ci.sh`, `ci.bat` або workflow на цьому етапі.

## Очікувані файли

- `Cargo.toml` з пакетом `hello`.
- `src/main.rs` із Hello World.
- `.gitignore` із `target/` (якщо його ще не створила команда Git Init).

## Команди перевірки

```text
git branch --show-current
test -f Cargo.toml
test -f src/main.rs
grep -F 'name = "hello"' Cargo.toml
```

На Windows використовуйте еквівалентні команди PowerShell. Перевірте також,
що `cargo metadata --no-deps --format-version 1` завершується успішно.

## Повідомлення про помилки

```text
FAIL create-project: <етап> завершився з кодом <код>: <деталі>
```

Якщо поточна гілка `develop`, зупинись із повідомленням без створення файлів.
Якщо Cargo недоступний або `cargo init` завершився помилкою, передай точний
вивід оркестратору.

## Ідемпотентність

Не запускай `cargo init`, якщо заповнений `Cargo.toml` і `src/main.rs` уже
існують. Не перезаписуй наявні файли та не додавай дублікати конфігурації.

