# Rust Hello World — Варіант 22

**Студент:** Совінський Андрій Іванович  
**Група:** КІ-406  
**Варіант:** 22  
**Мова:** Rust  
**Система збірки:** Cargo  
**Тестування:** `cargo test`

## Опис

Це мінімальний проєкт Rust із програмою Hello World і юніт-тестом, який
демонструє відтворювану локальну збірку та кросплатформну перевірку в GitHub
Actions. Custom agent `Build Engineer AI Agent` автоматизує проєктування
структури, налаштування Cargo, запуск тестів і підготовку CI/CD.

## Структура

- `Cargo.toml` — маніфест пакета Cargo;
- `src/main.rs` — точка входу та юніт-тест;
- `ci.sh` — локальна перевірка для Unix-подібних систем;
- `ci.bat` — локальна перевірка для Windows;
- `.github/agents/build-engineer.agent.md` — маніфест AI-агента;
- `.github/workflows/ci.yml` — GitHub Actions workflow з матрицею трьох ОС;
- `docs/architecture.md` — архітектура агента та потік виконання.

## Запуск агента через Copilot Chat

1. Відкрийте корінь цього репозиторію у VS Code з увімкненим Copilot Chat.
2. Відкрийте список custom agents і виберіть **Build Engineer AI Agent**.
   Агент завантажується з `.github/agents/build-engineer.agent.md`.
3. Надішліть завдання, наприклад: `Перевір структуру проєкту та запусти всі
   build і test етапи`.
4. Для первинної ініціалізації можна виконати `/init` у Copilot Chat, якщо
   ця команда доступна у встановленій версії VS Code. Якщо середовище
   підтримує prompt-файли, аналогічний сценарій можна зберегти як
   `.github/prompts/init.prompt.md` і запускати його з Copilot Chat.
5. Дочекайтеся послідовного звіту оркестратора: Inspect, Scaffold,
   Build and test, CI setup, Verify.

Агент має працювати тільки з файлами репозиторію. Не передавайте йому
секрети, токени або інші облікові дані.

## Локальна перевірка

Переконайтеся, що встановлено Rust toolchain з Cargo, потім виконайте:

```text
cargo fmt --check
cargo check
cargo build
cargo test
```

На Linux/macOS можна запустити об'єднану перевірку:

```sh
./ci.sh
```

На Windows у Command Prompt або PowerShell:

```bat
ci.bat
```

Запуск програми:

```text
cargo run
```

Очікуваний вивід — `Hello, world!`. GitHub Actions автоматично запускає
`cargo test` на Ubuntu, Windows і macOS.

