# Git Office Text Filter

Универсальный Git-фильтр для офисных документов. Позволяет просматривать различия в офисных файлах (PDF, DOCX, XLSX и др.) через `git diff`.

## Соответствие условию задания

Конфигурация соответствует требованиям задания:
```ini
[diff "pdf"]
    textconv = sh -c 'pdftotext -layout -enc UTF-8 "$0" -'
```

Каждый формат использует прямую команду конвертации, а не универсальный скрипт.

## Быстрый старт

### 1. Установите зависимости
```bash
chmod +x install-deps.sh
./install-deps.sh
```

### 2. Настройте Git
```bash
chmod +x setup-git.sh
./setup-git.sh
```

### 3. Добавьте в ваш проект `.gitattributes`:
```gitattributes
*.pdf diff=pdf
*.docx diff=docx
*.xlsx diff=xlsx
```

### 4. Теперь используйте как обычно:
```bash
git diff report.pdf
git diff document.docx
git diff spreadsheet.xlsx
```

## Поддерживаемые форматы

| Формат | Расширение | Используемая команда |
|--------|------------|---------------------|
| PDF | `.pdf` | `pdftotext -layout -enc UTF-8` |
| Word (новый) | `.docx` | `pandoc -f docx -t plain` |
| Word (старый) | `.doc` | `antiword` |
| Excel (новый) | `.xlsx` | `xlsx2csv` |
| Excel (старый) | `.xls` | `xls2csv` |
| Текст | `.txt` | `cat` |

## Как это работает

Git использует механизм `textconv` для преобразования бинарных файлов в текст перед сравнением:

1. При выполнении `git diff file.pdf` Git ищет конфигурацию `diff.pdf.textconv`
2. Запускает указанную команду с файлом как аргументом
3. Сравнивает вывод команд для двух версий файла

## Тестирование

```bash
# Создайте тестовый репозиторий
mkdir test-repo && cd test-repo
git init

# Скопируйте .gitattributes
cp ../shell_git_filter/.gitattributes .

# Настройте Git (если ещё не настроено)
../shell_git_filter/setup-git.sh

# Создайте тестовый PDF
echo "Hello World" > test.pdf
git add test.pdf
git commit -m "Add test"

# Измените файл
echo "Hello Git" > test.pdf

# Посмотрите различия
git diff test.pdf
```

## Альтернативный подход: Универсальный скрипт

Если прямой метод не работает (нет нужных конвертеров), можно использовать универсальный скрипт `office2text.sh`:

### Настройка:
```bash
# 1. Сделайте скрипт исполняемым
chmod +x office2text.sh

# 2. Настройте Git для всех форматов
git config --global diff.pdf.textconv "$(pwd)/office2text.sh"
git config --global diff.docx.textconv "$(pwd)/office2text.sh"
git config --global diff.xlsx.textconv "$(pwd)/office2text.sh"
git config --global diff.pptx.textconv "$(pwd)/office2text.sh"
git config --global diff.odt.textconv "$(pwd)/office2text.sh"
```

### Преимущества универсального скрипта:
- Автоматически определяет тип файла
- Имеет цепочку фолбэков (если нет одного конвертера, пробует другой)
- Поддерживает больше форматов "из коробки"
- Более устойчив к ошибкам

### Как переключиться обратно на прямые команды:
```bash
# Удалить универсальную настройку
git config --global --unset diff.pdf.textconv
# и т.д.

# Запустить setup-git.sh снова
./setup-git.sh
```
## Лицензия

MIT License

### Примечание по PowerPoint

Для файлов PowerPoint используется базовая конвертация через `strings`, которая извлекает только текстовые строки.
Для полноценной конвертации установите:
```bash
# Способ 1: через npm
npm install -g pptx2md

# Способ 2: через apt
sudo apt-get install unoconv
```

После установки перезапустите `./setup-git.sh`.
