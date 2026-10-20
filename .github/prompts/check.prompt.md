---
description: "Виконує повну перевірку структури агента, документації, CI та Rust-проєкту у форматі PASS/FAIL."
argument-hint: "Перевірити всі критерії проєкту"
agent: "Build Engineer AI Agent"
---

# Команда Check

## Передумови

- Проєкт згенерований у feature-гілці після `/init`.
- Доступні Git, Cargo і shell-команди.
- Перевірка не змінює файли.

## Дії

Перевір кожен пункт окремо та виведи рівно один рядок `PASS` або `FAIL` для
кожного критерію:

1. існує `.github/agents/build-engineer.agent.md`;
2. існують skills `.github/skills/project-scaffold/SKILL.md`,
   `.github/skills/build-and-test/SKILL.md`,
   `.github/skills/github-actions/SKILL.md`;
3. існують `README.md`, `docs/architecture.md`, `docs/usage.md`;
4. `.github/workflows/ci.yml` є валідним YAML;
5. `ci.yml` має тригери `push` і `pull_request` для `develop` та `master`;
6. `ci.yml` містить рівно три ОС: `ubuntu-latest`, `windows-latest`,
   `macos-latest`;
7. `ci.yml` не містить прямих викликів `cargo`;
8. `target/` не відстежується Git;
9. `cargo test` завершується успішно;
10. `cargo run` завершується успішно та виводить `Hello`.

Заверши команду ненульовим кодом, якщо будь-який пункт має `FAIL`.

## Очікувані файли

Ця команда нічого не створює. Вона лише перевіряє:

```text
.github/agents/build-engineer.agent.md
.github/skills/*/SKILL.md
README.md
docs/architecture.md
docs/usage.md
.github/workflows/ci.yml
Cargo.toml
src/main.rs
```

## Команди перевірки

Вивід повинен мати такий формат:

```text
PASS manifest: ...
FAIL ci-yaml: ...
```

Для кожного пункту додай коротку причину або доказ. Для YAML використай
доступний YAML-парсер або інший надійний валідатор, а не лише пошук тексту.
Для відсутності `target/` у Git використай:

```text
git check-ignore -q target/
```

## Повідомлення про помилки

```text
FAIL <пункт>: <точна причина>
```

Після всіх перевірок виведи підсумок `RESULT: PASS` або `RESULT: FAIL`.
При `RESULT: FAIL` заверши виконання з кодом помилки.

## Ідемпотентність

Команда є read-only: не створює, не перезаписує та не виправляє файли.
Повторний запуск виконує ті самі перевірки й формує зіставний звіт.

