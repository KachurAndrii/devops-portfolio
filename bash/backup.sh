#!/bin/bash
# ==========================
# 🔹 Automatic Backup Script
# ==========================

# КАТАЛОГ, який потрібно зберігати (1-й аргумент)
SOURCE_DIR="$1"
# КАТАЛОГ для зберігання резервних копій (2-й аргумент або за замовчуванням ./backups)
BACKUP_DIR="${2:-./backups}"

# ==========================
# 🔹 Перевірка аргументів
# ==========================
if [ -z "$SOURCE_DIR" ]; then
    echo "❌ Usage: $0 <source_directory> [backup_directory]"
    exit 1
fi

# ==========================
# 🔹 Підготовка директорій
# ==========================
mkdir -p "$BACKUP_DIR"
LOG_FILE="$BACKUP_DIR/backup.log"

# Функція для запису в лог
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# ==========================
# 🔹 Перевірка існування вихідної папки
# ==========================
if [ ! -d "$SOURCE_DIR" ]; then
    log "❌ ERROR: Directory $SOURCE_DIR does not exist!"
    exit 1
fi

# ==========================
# 🔹 Формування імені архіву з timestamp
# ==========================
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
ARCHIVE_NAME="backup-${TIMESTAMP}.tar.gz"
ARCHIVE_PATH="$BACKUP_DIR/$ARCHIVE_NAME"

# ==========================
# 🔹 Створення архіву
# ==========================
log "🚀 Starting backup of $SOURCE_DIR ..."
tar -czf "$ARCHIVE_PATH" "$SOURCE_DIR" >> "$LOG_FILE" 2>&1

if [ $? -eq 0 ]; then
    log "✅ Backup created successfully: $ARCHIVE_NAME"
else
    log "❌ Backup failed!"
    exit 1
fi

# ==========================
# 🔹 Очищення старих backup (залишаємо тільки 5 останніх)
# ==========================
log "🧹 Cleaning up old backups (keeping latest 5)..."
cd "$BACKUP_DIR"
ls -tp backup-*.tar.gz 2>/dev/null | grep -v '/$' | tail -n +6 | xargs -d '\n' rm -f --
log "✅ Cleanup complete."

log "🎉 Backup process finished successfully."
