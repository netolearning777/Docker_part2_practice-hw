!/bin/bash

# Прерывать выполнение скрипта при любой ошибке
set -e

# --- НАСТРОЙКИ ---
# URL репозитория
REPO_URL="https://github.com/netolearning777/Docker_part2-hw.git"
# Имя папки, в которую клонируется проект внутри /opt
PROJECT_DIR_NAME="my-project"
TARGET_DIR="/opt/$PROJECT_DIR_NAME"

# --- ПРОВЕРКА ПРАВ ---
if [ "$EUID" -ne 0 ]; then
  echo "Ошибка: Запустите скрипт с правами суперпользователя (используйте sudo)."
  exit 1
fi

# --- ПРОВЕРКА ЗАВИСИМОСТЕЙ ---
for cmd in git docker; do
  if ! command -v $cmd &> /dev/null; then
    echo "Ошибка: Утилита '$cmd' не установлена. Пожалуйста, установите её перед запуском."
    exit 1
  fi
done

# --- СКАЧИВАНИЕ / ОБНОВЛЕНИЕ РЕПОЗИТОРИЯ ---
if [ -d "$TARGET_DIR" ]; then
  echo "Директория $TARGET_DIR уже существует. Обновляем код..."
 cd "$TARGET_DIR"
  git pull
else
  echo "Клонируем репозиторий в $TARGET_DIR..."
  git clone "$REPO_URL" "$TARGET_DIR"
  cd "$TARGET_DIR"
fi

# --- НАСТРОЙКА ОКРУЖЕНИЯ ---
echo "Создаем файл .env с заданными параметрами..."
cat << 'EOF' > .env
MYSQL_ROOT_PASSWORD="YtReWq4321"
MYSQL_DATABASE="virtd"
MYSQL_USER="app"
MYSQL_PASSWORD="QwErTy1234"

DB_HOST="172.20.0.10"
DB_USER="app"
DB_PASSWORD="QwErTy1234"
DB_NAME="virtd"
EOF

# Ограничиваем права на чтение файла с паролями (только для владельца)
chmod 600 .env

# --- ЗАПУСК ПРОЕКТА ---
echo "Запускаем проект..."
if [ -f "compose.yml" ] || [ -f "compose.yaml" ]; then
  docker compose up -d --build
  echo "Проект успешно запущен в фоновом режиме!"
else
  echo "Файл compose.yml не найден. Убедитесь, что в репозитории есть инструкции по запуску."
  exit 1
fi
